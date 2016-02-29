import logging
import argparse
import sys
import tehin

parser = argparse.ArgumentParser()
parser.add_argument('-l', '--log', help='Output verbosity', default='INFO')
parser.add_argument('-i', '--input_file', help='Input data file')
parser.add_argument('-o', '--output_file', help='Output data file')
parser.add_argument('-c', '--class_column', help='Column of the data containing the class')
parser.add_argument('-d', '--descriptive_columns', help='Names of columns containing descriptive data', nargs='+')
# parser.add_argument('-w', '--weighing', help='Weight calculation method', default='rf',
#                     choices=['tf', 'chi', 'ig', 'gr', 'delta', 'idf', 'rf'])
# parser.add_argument('-s', '--summing', help='Weight aggregation method', default='sum',
#                     choices=['sum', 'weighted_sum'])
# parser.add_argument('-b', '--basic_type', help='Basic type on which to split', default='person')


def main():
    # features = True
    # if features:
    args = parser.parse_args()
    logging.basicConfig(level=args.log, format='%(asctime)s %(message)s', stream=sys.stdout)
    logging.info('Loading data...')
    network = tehin.read_graph_from_features(args.input_file,
                                             feature_columns=args.descriptive_columns,
                                             class_column=args.class_column)
    # network = tehin.read_graph_from_net('pakdd.net')
    logging.info('Loaded!')
    network.full_feature_vectors('decomposition')
    network.export_json(args.output_file, args.descriptive_columns, args.class_column)
    # else:
    #     args = parser.parse_args()
    #     logging.basicConfig(level=args.log, format='%(asctime)s %(message)s', stream=sys.stdout)
    #     logging.info('Loading data...')
    #     network = tehin.read_graph_from_net('pakdd.net')
    #     logging.info('Loaded!')
    #
    #     network.set_basic_type(args.basic_type)
    #
    #     network.split_to_ratio(1.0, 0.0, 0.0)
    #     network.decompose(['person', 'C_level', 'person'], ['person_bought_C_level', 'C_level_bought_by_person'],
    #                     name='decomposition', weighing=args.weighing, summing=args.summing)
    #     network.full_feature_vectors('decomposition')
    #
    #     network.export_json('test_export.json')
#
#
if __name__ == '__main__':
    main()