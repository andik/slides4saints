import unittest

from opensong import OpenSongTextualImporter as OTI, OpenSongImporter as OI

class TestTextImport(unittest.TestCase):
	def test_nosection(self):
			t = " abc"
			with self.assertRaises(RuntimeError):
				OTI(t).parse()

	def test_section(self):
		t = "[v1]\n"
		self.assertEqual(OTI(t).parse(), {"1": []})
	
	def test_text(self):
		t = "[v1]\n abc"
		self.assertEqual(OTI(t).parse(), {"1": [{"eng": "abc"}, {"!": "/"}]})	

	def test_text2(self):
		t = "[v1]\n abc\n def"
		self.assertEqual(OTI(t).parse(), {"1": [{"eng": "abc"}, {"!": "/"},
																						{"eng": "def"}, {"!": "/"}]})

	def test_multi(self):
		t = "[v]\n1abc\n2def"
		self.assertEqual(OTI(t).parse(), {"1": [{"eng": "abc"}, {"!": "/"}], 
																			"2": [{"eng": "def"}, {"!": "/"}]})

	def test_chords(self):
		t = ("[v1]\n"
		  + ".C    D\n"
		  + " abc  def\n")
		self.assertEqual(OTI(t).parse(), {"1": [{"#c": "C", "eng": "abc"}, 
												{"#c": "D", "eng": "def"}, 
												{"!": "/"}]})

	def test_chords2(self):
		t = ("[v1]\n"
		  + ".C    D\n"
		  + " abc  def\n"
		  + " ghi jkl"
		)
		self.assertEqual(OTI(t).parse(), {"1": 
			[{"#c": "C", "eng": "abc"}, 
			 {"#c": "D", "eng": "def"}, 
			 {"!": "/"},
			 {"eng": "ghi jkl"},
			 {"!": "/"},
		]})


if __name__=='__main__':
    unittest.main()