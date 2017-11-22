class LineOrientedParser(object):

	def __init__(self, text):
		self.lines = list(text.splitlines())
		self.linenum = -1
		self.numlines = len(self.lines)
		self.secs = []

	def read_line(self):
		if self.haslines():
			self.linenum += 1

			while len(self.lines[self.linenum])==0:
				if self.haslines():
					self.linenum += 1
				else:
					return None

			return self.lines[self.linenum]
		else:
			return None

	def unread_line(self):
		self.linenum -= 1

	def cur_line(self):
		return self.lines[self.linenum]

	def prev_line(self):
		return self.lines[self.linenum - 1]

	def haslines(self):
		return (self.linenum + 1 < self.numlines)