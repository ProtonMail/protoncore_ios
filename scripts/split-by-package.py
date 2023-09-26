#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET
import lxml.etree
import copy
import re
import os.path


## Workaround for https://gitlab.com/gitlab-org/gitlab/-/issues/328772. Pipeline artifacts are limited to
# 10M. So split the single cobertura xml (which is often >100M) into one file per package, since there
# seems to be no limit on the _number_ of files, jut their size.

def read_base_xml(filename):
    cobertura_file = open(filename, "rt")
    cobertura = lxml.etree.fromstring(cobertura_file.read())
    cobertura_file.close()
    return cobertura

def create_header_node(cobertura):
    header_node = copy.deepcopy(cobertura)
    packages_node = header_node.find('packages')

    # Delete all the package nodes from the XML
    for package_to_remove in packages_node:
        packages_node.remove(package_to_remove)

    return header_node

def create_package_file(cobertura_header, package, destination_path, packageNumber):
	
    filename = "cobertura-{}.xml".format(packageNumber)
    packageNumber = packageNumber + 1
    print("Creating package file {}".format(filename))
    xml_to_write = copy.deepcopy(cobertura_header)
    packages_node = xml_to_write.find('packages')

    # Add back the one package we want
    packages_node.append(package)

    package_file = open(filename, 'wb')
    package_file.write(lxml.etree.tostring(xml_to_write))
    package_file.close()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: split-by-package.py FILENAME [DESTINATION_PATH]")
        sys.exit(1)

    filename = sys.argv[1]
    packageNumber = 1

    print("Reading in Cobertura XML from {}".format(filename))
    cobertura_xml = read_base_xml(filename)
    cobertura_header = create_header_node(cobertura_xml)

    if len(sys.argv) > 1:
        destination_path = sys.argv[2]
        print("Writing output to {}".format(destination_path))
        os.chdir(destination_path)

    for package in cobertura_xml.find('packages'):
        create_package_file(cobertura_header, package, destination_path, packageNumber)
        packageNumber = packageNumber + 1
