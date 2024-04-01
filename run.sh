#! /bin/bash

# Just put a "." because everything is in the same directory
BASEDIR=.
OUTDIR=$BASEDIR/experiments

# Code for the experiment
CODE = 001

# ----
# Parser -> THIS IS WHAT WE NEED TO MODIFY
# Use: Convert Datasets, xml, to feature vectors (.feat)
# First, put info about the token (like the id, or the token). Then, a list of features (ex: prev-words)
# Do this for train and develop (# Note: Devel is like a test and "echo" is a print())
echo "Extracting features..."
python extract-features.py $BASEDIR/data/train/ > $OUTDIR/feat/$CODE-train.feat
python extract-features.py $BASEDIR/data/devel/ > $OUTDIR/feat/$CODE-devel.feat

# ----
# Use First model: CRF
# train CRF model
echo "Training CRF model..."
python train-crf.py $OUTDIR/crf/$CODE-model.crf < $OUTDIR/feat/$CODE-train.feat

# run CRF model
echo "Running CRF model..."
python predict.py $OUTDIR/crf/$CODE-model.crf < $OUTDIR/feat/$CODE-devel.feat > $OUTDIR/out/$CODE-devel-CRF.out

# evaluate CRF results
# Use the file .stats to know how good is the model
echo "Evaluating CRF results..."
python evaluator.py NER $BASEDIR/data/devel $OUTDIR/out/$CODE-devel-CRF.out > $OUTDIR/stats/$CODE-devel-CRF.stats

#Extract Classification Features
cat $OUTDIR/feat/$CODE-train.feat | cut -f5- | grep -v ^$ > $OUTDIR/feat/$CODE-train.clf.feat

# ----
# Use another classifier: Naive Bayes
# train Naive Bayes model
echo "Training Naive Bayes model..."
python train-sklearn.py $OUTDIR/joblib/$CODE-model.joblib $OUTDIR/joblib/$CODE-vectorizer.joblib < $OUTDIR/feat/$CODE-train.clf.feat
# run Naive Bayes model
echo "Running Naive Bayes model..."
python predict-sklearn.py $OUTDIR/joblib/$CODE-model.joblib $OUTDIR/joblib/$CODE-vectorizer.joblib < $OUTDIR/feat/$CODE-devel.feat > $OUTDIR/out/$CODE-devel-NB.out
# evaluate Naive Bayes results 
echo "Evaluating Naive Bayes results..."
python evaluator.py NER $BASEDIR/data/devel $OUTDIR/out/$CODE-devel-NB.out > $OUTDIR/stats/$CODE-devel-NB.stats

# remove auxiliary files.
rm $OUTDIR/feat/$CODE-train.clf.feat
