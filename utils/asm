#!/usr/bin/env python

import re, sys, collections, math
from pprint import pprint

class SyntaxError(Exception):
	def __init__(self, lineno, msg):
		self.lineno = lineno
		message = 'At line %d: %s' % (lineno, msg)
		super(SyntaxError, self).__init__(message)

# Configuration
ktextinit = 0x0000
kdatainit = 0x0400
textinit  = 0x1000
datainit  = 0x2000

token_def = [
#     Name           Pattern            Ignore
	( 'Whitespace' , '[\s]+'          , True  ),
	( 'Comment'    , '#.*'            , True  ),
	( 'Meta'       , '\.\w+'          , False ),
	( 'Label'      , '\w+:'           , False ),
	( 'String'     , '"[^"]*"'        , False ),
	( 'HexNumber'  , '0x[0-9a-fA-F]+' , False ),
	( 'Number'     , '-?\d+'          , False ),
	( 'Ident'      , '\w+'            , False ),
	( 'Register'   , '\$\w+'          , False ),
	( 'Comma'      , ','              , False ),
	( 'OpenPar'    , '\('             , False ),
	( 'ClosePar'   , '\)'             , False ),
	( 'Constant'   , '%\w+'           , False ),
]

patterns = [ (n,re.compile(p),i) for (n,p,i) in token_def ]

instructions = {
#   Name          Type  Opcode  Funct   Operands
	'add'     : ( 'R' , 0x0   , 0x20  , 'rd , rs , rt' ),
	'addi'    : ( 'I' , 0x8   , None  , 'rt , rs , imm' ),
	'sub'     : ( 'R' , 0x0   , 0x22  , 'rd , rs , rt' ),
	'and'     : ( 'R' , 0x0   , 0x24  , 'rd , rs , rt' ),
	'andi'    : ( 'I' , 0xc   , None  , 'rt , rs , imm' ),
	'or'      : ( 'R' , 0x0   , 0x25  , 'rd , rs , rt' ),
	'ori'     : ( 'I' , 0xd   , None  , 'rt , rs , imm' ),
	'xor'     : ( 'R' , 0x0   , 0x26  , 'rd , rs , rt' ),
	'xori'    : ( 'I' , 0xe   , None  , 'rt , rs , shamt' ),
	'sll'     : ( 'R' , 0x0   , 0x0   , 'rd , rs , shamt' ),
	'srl'     : ( 'R' , 0x0   , 0x2   , 'rd , rs , shamt' ),
	'sra'     : ( 'R' , 0x0   , 0x3   , 'rd , rs , shamt' ),
	'slt'     : ( 'R' , 0x0   , 0x2a  , 'rd , rs , rt' ),
	'beq'     : ( 'I' , 0x4   , None  , 'rs , rt , label' ),
	'bne'     : ( 'I' , 0x5   , None  , 'rs , rt , label' ),
	'bgt'     : ( 'P' , None  , None  , 'rs , rt , label' ),
	'bge'     : ( 'P' , None  , None  , 'rs , rt , label' ),
	'blt'     : ( 'P' , None  , None  , 'rs , rt , label' ),
	'ble'     : ( 'P' , None  , None  , 'rs , rt , label' ),
	'j'       : ( 'J' , 0x2   , None  , 'label' ),
	'jal'     : ( 'J' , 0x3   , None  , 'label' ),
	'jr'      : ( 'R' , 0x0   , 0x8   , 'rs' ),
	'move'    : ( 'P' , None  , None  , 'rd , rs' ),
	'lb'      : ( 'I' , 0x20  , None  , 'rt , imm ( rs )' ),
	'lui'     : ( 'I' , 0xf   , None  , 'rt , imm'),
	'lw'      : ( 'I' , 0x23  , None  , 'rt , imm ( rs )' ),
	'li'      : ( 'P' , None  , None  , 'rd , imm'),
	'la'      : ( 'P' , None  , None  , 'rd , label'),
	'sb'      : ( 'I' , 0x28  , None  , 'rt , imm ( rs )' ),
	'sw'      : ( 'I' , 0x2b  , None  , 'rt , imm ( rs )' ),
	'syscall' : ( 'R' , 0x0   , 0xc   , None ),
	'mfc0'    : ( 'I' , 0x10  , 0x0   , 'rt , rs' ),
	'mtc0'    : ( 'I' , 0x11  , 0x0   , 'rs , rt' ),
	'mul'     : ( 'R' , 0x0   , 0x18  , 'rd , rs , rt' ),
	'div'     : ( 'R' , 0x0   , 0x1a  , 'rd , rs , rt' ),
	'eret'    : ( 'I' , 0x12  , 0x0   , None ),
	'nop'     : ( 'P' , None  , None  , None ),
}

rules = {
#   Name        Pattern                       Ignore
	'rs'    : ( 'Register'                  , False ),
	'rt'    : ( 'Register'                  , False ),
	'rd'    : ( 'Register'                  , False ),
	'imm'   : ( 'HexNumber|Number|Constant' , False ),
	'shamt' : ( 'HexNumber|Number|Constant' , False ),
	'const' : ( 'Constant'                  , False ),
	'label' : ( 'Ident'                     , False ),
	','     : ( 'Comma'                     , True  ),
	'('     : ( 'OpenPar'                   , True  ),
	')'     : ( 'ClosePar'                  , True  ),
}

registers = {
#   Trivial     Normal        Floating P   Coproc0
	'0'  : 0  , 'zero' : 0  , 'f0'  : 0  ,
	'1'  : 1  , 'at'   : 1  , 'f1'  : 1  ,
	'2'  : 2  , 'v0'   : 2  , 'f2'  : 2  ,
	'3'  : 3  , 'v1'   : 3  , 'f3'  : 3  ,
	'4'  : 4  , 'a0'   : 4  , 'f4'  : 4  ,
	'5'  : 5  , 'a1'   : 5  , 'f5'  : 5  ,
	'6'  : 6  , 'a2'   : 6  , 'f6'  : 6  ,
	'7'  : 7  , 'a3'   : 7  , 'f7'  : 7  ,
	'8'  : 8  , 't0'   : 8  , 'f8'  : 8  ,
	'9'  : 9  , 't1'   : 9  , 'f9'  : 9  ,
	'10' : 10 , 't2'   : 10 , 'f10' : 10 ,
	'11' : 11 , 't3'   : 11 , 'f11' : 11 ,
	'12' : 12 , 't4'   : 12 , 'f12' : 12 , 'status' : 12 ,
	'13' : 13 , 't5'   : 13 , 'f13' : 13 , 'cause'  : 13 ,
	'14' : 14 , 't6'   : 14 , 'f14' : 14 , 'epc'    : 14 ,
	'15' : 15 , 't7'   : 15 , 'f15' : 15 ,
	'16' : 16 , 's0'   : 16 , 'f16' : 16 ,
	'17' : 17 , 's1'   : 17 , 'f17' : 17 ,
	'18' : 18 , 's2'   : 18 , 'f18' : 18 ,
	'19' : 19 , 's3'   : 19 , 'f19' : 19 ,
	'20' : 20 , 's4'   : 20 , 'f20' : 20 ,
	'21' : 21 , 's5'   : 21 , 'f21' : 21 ,
	'22' : 22 , 's6'   : 22 , 'f22' : 22 ,
	'23' : 23 , 's7'   : 23 , 'f23' : 23 ,
	'24' : 24 , 't8'   : 24 , 'f24' : 24 ,
	'25' : 25 , 't9'   : 25 , 'f25' : 25 ,
	'26' : 26 , 'k0'   : 26 , 'f26' : 26 ,
	'27' : 27 , 'k1'   : 27 , 'f27' : 27 ,
	'28' : 28 , 'gp'   : 28 , 'f28' : 28 ,
	'29' : 29 , 'sp'   : 29 , 'f29' : 29 ,
	'30' : 30 , 'fp'   : 30 , 'f30' : 30 ,
	'31' : 31 , 'ra'   : 31 , 'f31' : 31 ,
}

constants = { 
    'PRINT_HEX'   : 0x0,
	'PRINT_INT'   : 0x1,
	'PRINT_FLOAT' : 0x2,
    'PRINT_STR'   : 0x4,
    'PRINT_STRING': 0x4,
	'READ_INT'    : 0x5,
	'READ_FLOAT'  : 0x6,
	'EXIT'        : 0xa,
	'PRINT_CHAR'  : 0xb,
	'READ_CHAR'   : 0xc,
	'IO_EXIT'     : -1,
	'IO_CHAR'     : -2,
	'IO_INT'      : -3,
	'IO_FLOAT'    : -4,
	'IO_HEX'      : -5,
    'STACK_INIT'  : 0x10000,
}

def instrLen(opcode, operands):
	itype = instructions[opcode][0]
	if itype != 'P':     return 4
	if opcode == 'li':   return 8
	if opcode == 'la':   return 8
	if opcode == 'bgt':  return 8
	if opcode == 'bge':  return 8
	if opcode == 'blt':  return 8
	if opcode == 'ble':  return 8
	return 4

def dataLen(key, val):
	if key == '.ascii':
		return len('%s' % val[1:][:-1].decode('string_escape'))
	elif key == '.asciiz':
		return len('%s' % val[1:][:-1].decode('string_escape')) + 1
	elif key == '.byte':
		return len(val)
	elif key == '.half':
		return len(val) * 2
	elif key == '.word':
		return len(val) * 4
	elif key == '.space':
		return int(val[1])

class Parser(object):
	def __init__(self, stream):
		self.lines = stream.readlines()
		self.lineno = 0
		self.text = []
		self.data = []
		self.ktext = []
		self.kdata = []
		self.labels = {}
		self.parser = self.parsetext
	def start(self):
		for line in self.lines:
			self.lineno += 1
			tokens = self.tokenize(line)
			# Always at least end of line
			if len(tokens) > 1: self.parser(tokens)
		if not 'main' in self.labels:
			raise SyntaxError(self.lineno, 'No main label')
	def regToBin(self, reg):
		regname = reg[1][1:]
		if regname not in registers:
			raise SyntaxError(self, 'Register $%s unkown' % regname)
		return '{0:05b}'.format(registers[regname])
	def intToBin(self, num, nbits):
		fmt = '{0:0%db}' % nbits
		overflow = int('1'*nbits, 2) + 1;
		if num < 0:
			num = overflow + num
		if num >= overflow:
			raise SyntaxError(self.lineno, 'Number out of bounds %d %d %d'  % (maxnum, num, nbits))
		return fmt.format(num)
	def numToBin(self, num, nbits):
		ntype, ndata = num
		if ntype == 'Constant':
			if not ndata[1:] in constants:
				raise SyntaxError(self.lineno, 'Constant %s is undefined' % ndata)
			realnum = constants[ndata[1:]]
		elif ntype == 'Ident':
			if not ndata in self.labels:
				raise SyntaxError(self.lineno, 'Label %s unknown' % ndata)
			realnum = self.labels[ndata]
		elif ntype == 'HexNumber':
			realnum = int(ndata[2:], 16)
		else:
			realnum = int(ndata)
		return self.intToBin(realnum, nbits)
	def numToHex(self, num, digits):
		nbits = digits * 4
		fmt = '%%0.%dX' % digits
		return fmt % int(self.numToBin(num, nbits), 2)
	def tokenize(self, line):
		pos = 0
		tokens = []
		while pos < len(line):
			matched = False
			for name, pattern, ignore in patterns:
				match = pattern.match(line[pos:])
				if match:
					matched = True
					data = match.group()
					pos += match.end()
					if ignore: break
					tokens.append((name, data))
					break
			if not matched:
				raise SyntaxError(self.lineno, 'Unknown symbol')
		tokens.append(('end of line', None))
		return tokens
	def printcontext(self):
		ran = range(self.lineno - 1, self.lineno + 2)
		for i, ln, in enumerate(ran):
			if len(self.lines) >= ln and ln > 0:
				print >> sys.stderr,  '%s %3d | %s' % ('#' if self.lineno == ln else ' ', ln, self.lines[ln-1]),
	# Helpers for recursive descent parser
	def expect(self, tokens, pos, *choices):
		head = tokens[pos]
		for token in choices:
			if head[0] == token: return (pos+1, head)
		raise SyntaxError(self.lineno, 'Expected %s, found %s' % (' or '.join(choices), head[0]))
	def lookahead(self, tokens, pos, *choices):
		head = tokens[pos]
		for token in choices:
			if head[0] == token: return (pos+1, head)
		return None
	# Minimal parser
	def parseheader(self, tokens):
		pos, (_, section) = self.expect(tokens, 0, 'Meta')
		if section == '.data' or section == '.kdata':
			self.expect(tokens, pos, 'end of line')
			self.parser = self.parsedata
			self.section = self.data if section == '.data' else self.kdata
		elif section == '.text' or section == '.ktext':
			self.expect(tokens, pos, 'end of line')
			self.parser = self.parsetext
			self.section = self.text if section == '.text' else self.ktext
		else:
			raise SyntaxError(self.lineno, 'Invalid section %s' % section)
	def parsedata(self, tokens):
		# Detect end of section
		match = self.lookahead(tokens, 0, 'Meta')
		if match: return self.parseheader(tokens)
		pos, (_, label) = self.expect(tokens, 0, 'Label')
		label = label[:-1]
		if label in self.labels:
			raise SyntaxError(self.lineno, 'Duplicate label %s' % label)
		self.labels[label] = 0
		self.section.append((self.lineno, '@label', label))
		pos, (_, datatype) = self.expect(tokens, pos, 'Meta')
		val = None
		if datatype == '.ascii' or datatype == '.asciiz':
			pos, (_, val) = self.expect(tokens, pos, 'String')
		elif datatype == '.byte' or datatype == '.half' or datatype == '.word':
			val = []
			pos, num = self.expect(tokens, pos, 'Number', 'HexNumber', 'Ident')
			val.append(num)
			more = self.lookahead(tokens, pos, 'Comma')
			while more:
				pos, num = self.expect(tokens, more[0], 'Number', 'HexNumber', 'Ident')
				val.append(num)
				more = self.lookahead(tokens, pos, 'Comma')
		elif datatype == '.space':
			pos, val = self.expect(tokens, pos, 'Number')
		else:
			raise SyntaxError(self.lineno, 'Unexpected %s' % datatype)
		self.section.append((self.lineno, datatype, val))
	def parsetext(self, tokens):
		# Detect end of section
		match = self.lookahead(tokens, 0, 'Meta')
		if match: return self.parseheader(tokens)
		pos = 0
		match = self.lookahead(tokens, 0, 'Label')
		if match:
			pos, (_, label) = match
			label = label[:-1]
			if label in self.labels:
				raise SyntaxError(self.lineno, 'Duplicate label %s' % label)
			self.labels[label] = 0
			self.section.append((self.lineno, '@label', label))
			if not self.lookahead(tokens, pos, 'Ident'): return
		pos, (_, opcode) = self.expect(tokens, pos, 'Ident')
		if opcode not in instructions:
			raise SyntaxError(self.lineno, 'Unknown opcode %s' % opcode)
		operands = {}
		rule = instructions[opcode][3]
		if rule:
			for op in rule.split(' '):
				choices, ignore = rules[op]
				pos, tkn = self.expect(tokens, pos, *choices.split('|'))
				if not ignore: operands[op] = tkn
		self.section.append((self.lineno, opcode, operands))
	def finish(self):
		self.calcLabels()
		self.printout()
	def calcLabels(self):
		datapos = kdatainit
		for lineno, key, val in self.kdata:
			if key == '@label':
				self.labels[val] = datapos
			else:
				offset = dataLen(key, val)
				# Data is word aligned by default
				datapos += offset + (4 - offset % 4)
		textpos = ktextinit
		for lineno, texttype, value in self.ktext:
			if texttype == '@label':
				self.labels[value] = textpos
			else:
				textpos += instrLen(texttype, value)
		datapos = datainit
		for lineno, key, val in self.data:
			if key == '@label':
				self.labels[val] = datapos
			else:
				offset = dataLen(key, val)
				# Data is word aligned by default
				datapos += offset + (4 - offset % 4)
		textpos = textinit
		for lineno, texttype, value in self.text:
			if texttype == '@label':
				self.labels[value] = textpos
			else:
				textpos += instrLen(texttype, value)
	def printout(self):
		print '; .ktext'
		offset = 0
		for lineno, key, val in self.ktext:
			self.lineno = lineno
			offset = self.printtext(offset, key, val)
		print '; .kdata'
		for lineno, key, val in self.kdata:
			self.lineno = lineno
			self.printdata(key, val)
		print '; .text'
		offset = 0
		for lineno, key, val in self.text:
			self.lineno = lineno
			offset = self.printtext(offset, key, val)
		print '; .data'
		for lineno, key, val in self.data:
			self.lineno = lineno
			self.printdata(key, val)
	def printstring(self, value):
		escaped = value.decode('string_escape')
		for i in range(0, len(escaped), 4):
			ca = escaped[i]
			cb = escaped[i+1] if i+1 < len(escaped) else None
			cc = escaped[i+2] if i+2 < len(escaped) else None
			cd = escaped[i+3] if i+3 < len(escaped) else None
			print '\t%0.2X%0.2X%0.2X%0.2X ;' % (
				ord(cd) if cd else 0,
				ord(cc) if cc else 0,
				ord(cb) if cb else 0,
				ord(ca)
			),
			print '%s%s%s%s' % (
				ca.encode('string_escape'),
				cb.encode('string_escape') if cb else '',
				cc.encode('string_escape') if cc else '',
				cd.encode('string_escape') if cd else ''
			)
	def printdata(self, key, val):
		if key == '@label':
			print '%0.8X: ; <%s>' % (self.labels[val], val)
		else:
			print '\t; %s' % key
			if key == '.ascii':
				self.printstring(val[1:][:-1])
			elif key == '.asciiz':
				self.printstring(val[1:][:-1]+'\0')
			elif key == '.byte':
				for i in range(0, len(val), 4):
					va = val[i]
					vb = val[i+1] if i+1 < len(val) else None
					vc = val[i+2] if i+2 < len(val) else None
					vd = val[i+3] if i+3 < len(val) else None
					print '\t%s%s%s%s ;' % (
						self.numToHex(vd, 2) if vd else '00',
						self.numToHex(vc, 2) if vc else '00',
						self.numToHex(vb, 2) if vb else '00',
						self.numToHex(va, 2)
					),
					print '%s' % va[1] ,
					if vb: print ', %s' % vb[1] ,
					if vc: print ', %s' % vc[1] ,
					if vd: print ', %s' % vd[1] ,
					print ''
			elif key == '.half':
				for i in range(0, len(val), 2):
					va = val[i]
					vb = val[i+1] if i+1 < len(val) else ('Number', '0')
					print '\t%s%s ;' % (
						self.numToHex(vb, 4),
						self.numToHex(va, 4)
					),
					print '%s' % va[1] ,
					if vb: print ', %s' % vb[1] ,
					print ''
			elif key == '.word':
				for w in val:
					print '\t%s ; %s' % (self.numToHex(w, 8), w[1])
			elif key == '.space':
				print '\t; %s' % val[1]
	def instrToStr(self, opcode, operands):
		rule = instructions[opcode][3]
		instr = ['%s' % opcode]
		if rule:
			for op in rule.split(' '):
				if op in operands:
					instr.append('%s' % operands[op][1])
				else:
					instr.append('%s' % op)
		return ' '.join(instr)
	def printtext(self, pos, key, val, info=None):
		if key == '@label':
			print '%0.8x: ; <%s>' % (self.labels[val], val)
			pos = self.labels[val]
		else:
			itype, opcode, funct = instructions[key][:3]
			binary = '0' * 32
			if itype == 'R':
				binary = '{0:06b}'.format(opcode)
				binary += self.regToBin(val['rs']) if 'rs' in val else '00000'
				binary += self.regToBin(val['rt']) if 'rt' in val else '00000'
				binary += self.regToBin(val['rd']) if 'rd' in val else '00000'
				binary += self.numToBin(val['shamt'], 5) if 'shamt' in val else '00000'
				binary += '{0:06b}'.format(funct)
				pos += 4
			elif itype == 'I':
				binary = '{0:06b}'.format(opcode)
				binary += self.regToBin(val['rs']) if 'rs' in val else '00000'
				binary += self.regToBin(val['rt']) if 'rt' in val else '00000'
				if 'imm' in val:
					binary += self.numToBin(val['imm'], 16)
				elif 'label' in val:
					label = val['label'][1]
					if label not in self.labels:
						raise SyntaxError(lineno, 'Label %s undefined' % label)
					offset = self.labels[label] - pos
					binary += self.intToBin(offset/4-1, 16)
				else:
					binary += '0' * 16
					pass
				pos += 4
			elif itype == 'J':
				binary = '{0:06b}'.format(opcode)
				label = val['label'][1]
				if label not in self.labels:
					raise SyntaxError(lineno, 'Label %s undefined' % label)
				binary += self.intToBin(self.labels[label],28)[:-2]
				pos += 4
			elif itype == 'P':
				if key == 'move':
					pos = self.printtext(pos, 'add', {
						'rs' : val['rs'], 'rd' : val['rd']
					}, self.instrToStr(key, val))
				elif key == 'li':
					numbin = self.numToBin(val['imm'], 32)
					pos = self.printtext(pos, 'lui', {
						'rt' : val['rd'],
						'imm' : ('Number', str(int(numbin[0:16],2)))
					}, self.instrToStr(key, val))
					pos = self.printtext(pos, 'ori', {
						'rt' : val['rd'], 'rs' : val['rd'],
						'imm' : ('Number', str(int(numbin[16:32],2)))
					}, '...')
				elif key == 'la':
					numhex = '%0.8X' % self.labels[val['label'][1]]
					pos = self.printtext(pos, 'lui', {
						'rt' : val['rd'],
						'imm' : ('HexNumber', '0x'+numhex[0:4])
					}, self.instrToStr(key, val))
					pos = self.printtext(pos, 'ori', {
						'rt': val['rd'],
						'imm' : ('HexNumber', '0x'+numhex[4:8])
					}, '...')
				elif key == 'nop':
					pos = self.printtext(pos, 'sll', {}, 'nop')
				elif key == 'bgt':
					pos = self.printtext(pos, 'slt', {
						'rd': ('Register', '$at'),
						'rs': val['rt'],
						'rt': val['rs']
					}, self.instrToStr(key, val))
					pos = self.printtext(pos, 'bne', {
						'rs': ('Register', '$at'),
						'rt': ('Register', '$0'),
						'label': val['label'],
					}, '...')
				elif key == 'bge':
					pos = self.printtext(pos, 'slt', {
						'rd': ('Register', '$at'),
						'rs': val['rs'],
						'rt': val['rt']
					}, self.instrToStr(key, val))
					pos = self.printtext(pos, 'beq', {
						'rs': ('Register', '$at'),
						'rt': ('Register', '$0'),
						'label': val['label'],
					}, '...')
				elif key == 'blt':
					pos = self.printtext(pos, 'slt', {
						'rd': ('Register', '$at'),
						'rs': val['rs'],
						'rt': val['rt']
					}, self.instrToStr(key, val))
					pos = self.printtext(pos, 'bne', {
						'rs': ('Register', '$at'),
						'rt': ('Register', '$0'),
						'label': val['label'],
					}, '...')
				elif key == 'ble':
					pos = self.printtext(pos, 'slt', {
						'rd': ('Register', '$at'),
						'rs': val['rt'],
						'rt': val['rs']
					}, self.instrToStr(key, val))
					pos = self.printtext(pos, 'beq', {
						'rs': ('Register', '$at'),
						'rt': ('Register', '$0'),
						'label': val['label'],
					}, '...')
				return pos
			print '\t%0.8X' % int(binary, 2) ,
			if info == None:
				print '; %s' % self.instrToStr(key, val)
			else: print '; %s' % info
		return pos

def repl(stream):
	try:
		parser = Parser(stream)
		parser.start()
		parser.finish()
	except SyntaxError as ex:
		print >> sys.stderr,  ex.message
		parser.printcontext()
		sys.exit(1)

def main():
	if len(sys.argv) < 2: 
		while True:
			try:
				repl(sys.stdin)
			except KeyboardInterrupt:
				exit(0)
	else:
		with open(sys.argv[1], 'r') as content: repl(content)

if __name__ == '__main__':
	main()
