import logging
import argparse
import sys
import json, urllib2
import numpy as np
from sklearn.cross_validation import train_test_split
from sklearn import svm

parser = argparse.ArgumentParser()
parser.add_argument('-l', '--log', help='Output verbosity', default='INFO')
parser.add_argument('-i', '--input_file', help='Input data file')
parser.add_argument('-0', '--output_file', help='Output data file')
parser.add_argument('-c', '--class_column', help='Column of the data containing the class')
parser.add_argument('-p', '--positive_class', help='Positive class. Others are all negative.')
parser.add_argument('-t', '--graph_type', help='Type of the chart to draw')
parser.add_argument('-d', '--descriptive_columns', help='Names of columns containing descriptive data', nargs='+')
# parser.add_argument('-w', '--weighing', help='Weight calculation method', default='rf',
#                     choices=['tf', 'chi', 'ig', 'gr', 'delta', 'idf', 'rf'])
# parser.add_argument('-s', '--summing', help='Weight aggregation method', default='sum',
#                     choices=['sum', 'weighted_sum'])
# parser.add_argument('-b', '--basic_type', help='Basic type on which to split', default='person')


def read_json(data_file, descriptive_columns, class_column, positive_class):
    with open(data_file) as f:
        data = json.load(f)
    X = []
    y = []
    for item in data:
        X.append(np.array([item[descriptive_column] for descriptive_column in descriptive_columns]))
        y.append(1 if item[class_column] == positive_class else 0)
    feature_min = X[0]
    feature_max = X[0]
    for i in range(1, len(y)):
        feature_min = np.minimum(feature_min, X[i])
        feature_max = np.maximum(feature_max, X[i])
    for i in range(len(X)):
        X[i] = (X[i] - feature_min) / (feature_max - feature_min)
    return X, y


def main():
    # features = True
    # if features:
    import sys
    print sys.argv
    print "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    args = parser.parse_args()
    logging.basicConfig(level=args.log, format='%(asctime)s %(message)s', stream=sys.stdout)
    logging.info('Loading data...')
    X, y = read_json(args.input_file, args.descriptive_columns, args.class_column, args.positive_class)
    logging.info('Loaded!')
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20)
    clf = svm.SVC(class_weight='balanced')
    clf.fit(X_train, y_train)
    clf.predict(X_test)
    data = json.dumps({
        "chart": args.graph_type,
        "data": [{"name": "alg1",
                  "actual": y_test,
                  "predicted": list(clf.decision_function(X_test))}]
    })
    url = "http://viper.ijs.si/api/"
    req = urllib2.Request(url, data)
    req.add_header('Content-Type', 'application/json')
    response = urllib2.urlopen(req)
    with open(args.output_file, 'w') as f:
        f.write(json.dumps({"result": json.loads(response.read())['url']}))

#
#
if __name__ == '__main__':
    main()