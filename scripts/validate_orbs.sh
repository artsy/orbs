#!/bin/bash

for orb in src/**/*.yml; do circleci orb validate $orb; done