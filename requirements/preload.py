import nltk

resources = ['punkt','maxent_treebank_pos_tagger','averaged_perceptron_tagger','maxent_ne_chunker'
    'words','stopwords']

for res in resources:
    nltk.download(res)