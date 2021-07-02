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


def get_dir_structure(target_dir):
    """
    Gets all children folders and files and saves information of all files within a folder in dictionary.

    Params:
        target_dir: string - path to directory that contains data

    Returns:
        folder_structure: dict - with subdirectories as keys and contained files as list of values
    """
    folder_structure = {}

    for current_dir, _, files in os.walk(target_dir):
        # full_path = target_dir + os.sep + current_dir
        new_files = [file for file in files if file != '.DS_Store']
        if new_files:
            folder_structure[current_dir] = new_files

    # print(folder_structure)  ##uncomment for troubleshooting
    return folder_structure


def extract_study_names(folder_structure):
    """
    Iterates of folders and files containing data of interest, locates file containing analzsis steps (incl. sample names)
    and extracts sample names for each study.
    Prints out information of number of studies, study names and samples corresponding to each study in JSON format.

    Params:
        folder_structure: dict - with subdirectories =as keys and contained files as list of values
    
    Returns:
        sample_info: dict - studies are keys; samples corresponding to each study are values (list)
    """
    # iterate over study-directories and extract sample names corresponding to each study - using regex
    sample_regex = r'/(SRR.\d*).sra'
    sample_info = {}
    for folder, files in folder_structure.items():
        print(f'folder: {folder}')
        study_name = folder.split("\\")[-1].split("-")[0]
        sample_info[study_name] = {}
        print(f"Extracting file names from study named {study_name}")
        sample_info[study_name]['files'] = []
        sample_info[study_name]['path'] = folder
    #     print(f'study name: {study_name}')
        for file in files:
            
            if 'List-Steps' in file: 
    #             save file content to string
                with open (f'{folder}{os.sep}{file}', "r") as myfile:
                    file_text=myfile.read().replace('\n', '')
                
    #             save sample patterns in variable
                study_samples = re.findall(sample_regex, file_text)
        
                # link study name with corresponding samples in dict
                sample_info[study_name]['samples'] = study_samples
    # #             uncomment for troubleshooting or info
    #             print(f'\tFile "{file} with {len(list(study_samples))} samples: {list(study_samples)}"\n')

            else:
                sample_info[study_name]['files'].append(file)
            

    print(f'\n{len(sample_info)} studies containing the following samples available:\n', json.dumps(sample_info, sort_keys=True, indent=4))

    return sample_info


def extract_sample_info(df, study_name, sample_names, parameter):
    """
    Extracts RNA-seq information from dataframe and prints the information to screen.

    Params:
        df: pandas DataFrame - contains RNA-seq information for different parameters of RNA-seq study
        study_name: string - name of study corresponding to data
        sample_names: list - samples within the study
        parameter: string - count metric contained in current data; accepted values: 'cpm', 'rpkm', 'tpm'

    Returns:
        data: dict - contains relevant information for current df
    """
    data = {}
    data['gene_info'] = {}
    data['sample_info'] = {}
    data['gene_expr'] = {}
    for row in df.index:
        if row < 5:
            current_cond = None
            cols = df.loc[row,:].to_frame().T.columns
            # print(f"Columns: {list(cols)}")

            #get sample-unspecific parameters for study-gene combination
            ensembl_id = df.loc[row, 'Ensembl Gene ID']
            gene_symbol = df.loc[row, 'Gene Symbol']
            print(f"Current gene symbol: {gene_symbol}")
            biotype = df.loc[row, 'Biotype']
            logFC = df.loc[row, 'logFC'] if 'logFC' in cols else np.nan
            logCPM = df.loc[row, 'logCPM'] if 'logCPM' in cols else np.nan
            lr = df.loc[row, 'LR'] if 'LR' in cols else np.nan
            pval = df.loc[row, 'PValue'] if 'PValue' in cols else np.nan
            fdr = df.loc[row, 'FDR'] if 'FDR' in cols else np.nan   
            counter = 0

            for column in cols:   
                # conditions for columns to exclude - excluded columns are non-condition columns
                no_ensembl = ('Ensembl' not in column)
                no_gsymbl = (column != 'Gene Symbol')
                no_biotype = (column != 'Biotype')
                no_FC = (column != 'logFC')
                no_cpm = (column != 'logCPM')
                no_LR = (column != 'LR')
                no_pval = (column != 'PValue')
                no_FDR = (column != 'FDR')

                data['gene_info'][gene_symbol] = {}

                if no_biotype and no_cpm and no_ensembl and no_FC and no_FDR and no_gsymbl and no_LR and no_pval:
                    sample_name = sample_names[counter]
                    if sample_name not in data['sample_info']:  #make sure older entries (of different paramaters (cpm, rpkm etc.) from different files are not overwritten or deleted)
                        data['sample_info'][sample_name] = {}
                    if sample_name not in data['gene_expr']:
                        data['gene_expr'][sample_name] = {}
                    if gene_symbol not in data['gene_expr'][sample_name]:
                        data['gene_expr'][sample_name][gene_symbol] = {}

    #                 print(sample_name, ':', column)  ##uncomment for troubleshooting
                    counter +=1
                    try:
                        if '.' in column:
                            condition, replicate = column.split(".")
                            current_cond = current_cond if (current_cond == condition ) else None
                            replicate = int(replicate)+1 if current_cond else int(replicate)
                        elif '_' in column:
                            condition, replicate = column.split("_")
                            current_cond = current_cond if (current_cond == condition ) else None
                            replicate = int(replicate)+1 if current_cond else int(replicate)
                        else:
                            condition = column
                            replicate = 1
                            current_cond = condition
                            replicate = int(replicate)
                        #     # print(column, "!!!!")
                        #     # print(f"Columns: {cols}")
                    except ValueError:
                        condition = column 
                        replicate = 1
                        current_cond = condition
                        print(f"EXCEPT 1 in columns {column}")
                    except UnboundLocalError:
                        condition = column
                        replicate = 1
                        print("EXCEPT 2")
                    col_val = df.loc[row, column]
                    if isinstance(col_val, float) or  isinstance(col_val, int):
                        # print(f"Value for sample {sample_name} - condition {column}: {col_val};\t\t\treplicate:{replicate}")

                        if 'condition' not in data['sample_info'][sample_name]:
                            data['sample_info'][sample_name]['condition'] = condition
                        if 'replicate' not in data['sample_info'][sample_name]:
                            data['sample_info'][sample_name]['replicate'] = replicate
                        data['gene_expr'][sample_name][gene_symbol][parameter] = col_val
                        
            # print('\n')
        
            data['gene_info'][gene_symbol]['ensembl_ID'] = ensembl_id
            # data['gene_symbol'] = gene_symbol
            data['gene_info'][gene_symbol]['biotype'] = biotype
            data['gene_info'][gene_symbol]['logFC'] = logFC
            data['gene_info'][gene_symbol]['logCPM'] = logCPM
            data['gene_info'][gene_symbol]['LR'] = lr
            data['gene_info'][gene_symbol]['pval'] = pval
            data['gene_info'][gene_symbol]['FDR'] = fdr

    # print(data)
    return data
 


def load_sample_data(path, file_name):
    extension = file_name.split(".")[-1]

    if extension == 'txt':
        df = pd.read_csv(f'{path}{os.sep}{file_name}', sep='\t', index_col=False)
    elif extension == 'csv':
        df = pd.read_csv(f'{path}{os.sep}{file_name}', index_col=False)
    else:
        print("File extension not accepted!\nAccepted Extentions: .txt , .csv\n")
        df = None

    return df


if __name__ == "__main__":
    data_structure = get_dir_structure(f'data{os.sep}Fibroblast-Fibrosis')
    sample_info = extract_study_names(data_structure)

    gene_exp = {}
    samples = {}
    degs = {}
    for study, study_info in sample_info.items():
        degs[study] = {}
        print(f"\n\n ---------- {study} ---------- \n")
        path = study_info['path']
        sample_names = study_info['samples']
        for file in study_info['files']:
            print(f"Loading data for file named: {file}")
            df = load_sample_data(path, file)
            file_param = 'cpm' if 'cpm' in file.lower() else 'rpkm' if 'rpkm' in file.lower() else 'tpm' if 'tpm' in file.lower() else 'Unknown'
            new_data = extract_sample_info(df, study, sample_names, file_param)
            print(new_data, '\n')

            for gene_name, gene_info in new_data['gene_info'].items():
                ensembl_ID = gene_info['ensembl_ID']
                gene_symbol = gene_name
                biotype = gene_info['biotype']
                logFC = gene_info['logFC']
                logCPM = gene_info['logCPM']
                lr = gene_info['LR']
                pval = gene_info['pval']
                padj = gene_info['FDR']
                if gene_symbol not in degs[study]:
                    degs[study][gene_symbol] = {}
                    for deg_param_name, deg_param_value in zip(['ensembleID', 'biotype', 'logFC', 'logCPM', 'LR', 'pval', 'padj'], 
                                                            [ensembl_ID, biotype, logFC, logCPM, lr, pval, padj]):
                        if deg_param_name not in degs[study][gene_symbol]:
                            degs[study][gene_symbol][deg_param_name] = deg_param_value

            for entry, entry_info in new_data['sample_info'].items():
                if isinstance(entry_info, dict):
                    if entry not in samples:
                        samples[entry] = {}
                    for param, param_value in entry_info.items():
                        if param not in samples[entry]:
                            samples[entry][param] = param_value

            for sample_name, sample_data in new_data['gene_expr'].items():
                if sample_name not in gene_exp:
                    gene_exp[sample_name] = {}
                for gene, gene_data in sample_data.items():
                    if gene not in gene_exp[sample_name]:
                        gene_exp[sample_name][gene] = {}
                    for expr_param, expr_value in gene_data.items():
                        gene_exp[sample_name][gene][expr_param] = expr_value


    # convert dicts to dfs and save info as csv
    degs_df = pd.DataFrame.from_dict(degs)
    degs_df.to_csv(f'test_output_data{os.sep}degs.csv')
    samples_df = pd.DataFrame.from_dict(samples)
    samples_df.to_csv(f'test_output_data{os.sep}samples.csv')
    expr_df = pd.DataFrame.from_dict(gene_exp)
    expr_df.to_csv(f'test_output_data{os.sep}gene_expr.csv')

    

        # SAMPLE 
        # self.sampleID = sample_id
        # self.studyID = study_id
        # self.condition = condition
        # self.replicate = replicate
        # self.tissue = tissue
        # self.timepoint = timepoint
        # self.treatment = treatment
        # self.study_info = study_info

        # # DEGS
        # # self.degs_id = degs_id
        # # self.gene_id = gene_id
        # # self.study_id = study_id
        # # self.log2FC = log2FC
        # # self.log2CPM = log2CPM
        # # self.pval = pval
        # # self.padj = padj
        # # self.lr = lr

        # EXPRESSION
        # self.expression_id = expression_id
        # self.gene_id = gene_id
        # self.sample_id = sample_id
        # self.tpm = tpm
        # self.cpm = cpm
        # self.rpkm = rpkm


    # print(data)

    # print(df)
    #     for i in data_structure[study]:
    #         print(i)
        # for path, file_list in study:
        #     for file in file_list:
        #         print(f"Loading data from sample: ")
        #         load_sample_data(path, file)
