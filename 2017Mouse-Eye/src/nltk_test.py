# python 3
# Test nltk applying on our annotation results
import nltk

#sentence = """'a laptop and a mouse'"""
sentence = """'There is a room where the drapes are open so natural sunlight enters the room. There is a brown leather couch with folded clothes and a pillow on it. There are potted plants along the side of the room in front of the windows. There is a wooden table with a laptop on it, a lamp, binder, remote and newspaper on it.'"""
tokens = nltk.word_tokenize(sentence)
tokens

tagged = nltk.pos_tag(tokens)
tagged