"""
This script takes a directory with: multiple subdirectories containing RNA-Seq data and one file listing the analysis steps (incl. sample names).

Sample names are extracted from the analysis-step text file.
Information from the text files containing RNA-Seq data, will be transformed and extracted, in order to prepare to load the relevant information into a databse.
"""

# imports
import pandas as pd
import os
import re
import numpy as np
import json


# get list of files and folders in target directory
folder_structure = {}
for current_dir, _, files in os.walk(f'data{os.sep}Fibroblast-Fibrosis'):
    new_files = [file for file in files if file != '.DS_Store']
    if new_files:
        folder_structure[current_dir] = new_files
# print(folder_structure)  ##uncomment for troubleshooting


# iterate over study-directories and extract sample names corresponding to each study - using regex
sample_regex = r'/(SRR.\d*).sra'
sample_info = {}
for folder, files in folder_structure.items():
    # print(f'folder: {folder}')
    study_name = folder.split("\\")[2].split("-")[0]
    print(f"Extracting file names from study named {study_name}")
#     print(f'study name: {study_name}')
    for file in files:
        if 'List-Steps' in file: 
#             save file content to string
            with open (f'{folder}{os.sep}{file}', "r") as myfile:
                file_text=myfile.read().replace('\n', '')
            
#             save sample patterns in variable
            study_samples = re.findall(sample_regex, file_text)
    
# #             uncomment for troubleshooting or info
#             print(f'\tFile "{file} with {len(list(study_samples))} samples: {list(study_samples)}"\n')
    
#             link study name with corresponding samples in dict
            sample_info[study_name] = study_samples

print(f'\n{len(sample_info)} studies containing the following samples available:\n', json.dumps(sample_info, sort_keys=True, indent=4))
