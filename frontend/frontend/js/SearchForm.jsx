import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import Autocomplete from '@material-ui/lab/Autocomplete';
import  { Redirect } from 'react-router-dom';
import { SERVER_BASE } from './constants';
import Grid from '@material-ui/core/Grid';
import { useHistory } from "react-router-dom";

export default function SearchForm() {
    let history = useHistory();

    const [searchTerm, setTerm] = useState("");
    const [localData, setData] = useState({ hits: [] });
    const [error, setError] = useState(null);
    const [isLoaded, setIsLoaded] = useState(false);
    const [inputValue, setInputValue] = React.useState('');
    const [Value, setValue] = React.useState('');
    const [geneoptions, setOptions] = useState([]);
    const [optionlabels, setLabels] = useState([]);

    const handleSubmit = (e) => {
        e.preventDefault();
        setTerm(inputValue);
        history.push('/genes/'+inputValue);
    }
    

    useEffect(() => {
      fetch(SERVER_BASE + "gene-aliases?alias_symbol="+inputValue)
      .then(res => res.json())
      .then(
        (result) => {
          for(let i = 0; i < result.length; i++) {
            fetch(SERVER_BASE + "gene-info?gene_id=" + result[i]["gene_id"])
            .then(res => res.json())
            .then(
              (result2) => {  
                result[i].name = result2[0].gene_symbol + " (" + result2[0].description + ")";
                setOptions(geneoptions => [...geneoptions, {...result[i]}]);
              }
            )
          }
          setIsLoaded(true);
        },
        (error) => {
          setIsLoaded(true);
        }
      );
    }, [inputValue]);


    return <div>
        <form onSubmit={handleSubmit}>
        <Autocomplete
      id="country-select-demo"
      style={{ width: 300 }}
      options={geneoptions}
      autoHighlight

      value={Value}
      getOptionLabel={(option) => option.gene_id}

      renderOption={(option) => { console.log("option", option.name, option); return (<Grid container alignItems="center">
        {option.name}
      </Grid>);}}

      filterOptions={x => x}
      onChange={(event, newValue) => {
        setValue(newValue);

      }}

      onInputChange={(event, newInputValue) => {
        event.preventDefault();
        setOptions([]);
        setInputValue(newInputValue);
        setIsLoaded(false);
      }}
      inputValue={inputValue}

      renderInput={(params) => (
        <TextField
          {...params}
          label="Look up a gene"
          variant="outlined"
          inputProps={{
            ...params.inputProps,
            autoComplete: 'off', // disable autocomplete and autofill
          }}
        />)}
        />
        </form>
        <h1>{searchTerm}</h1>
    </div>
} 