import Plot from 'react-plotly.js';
import axios from 'axios';
import React, { useState, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import Autocomplete from '@material-ui/lab/Autocomplete';
import  { Redirect } from 'react-router-dom';

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

    const handleSubmit = (e) => {
        e.preventDefault();
        setTerm(inputValue);
        history.push('/genes/'+inputValue);
    }
    

    return <div>
        <form onSubmit={handleSubmit}>
        <Autocomplete
      id="country-select-demo"
      style={{ width: 300 }}
      options={geneoptions}
      autoHighlight

      value={Value}
      getOptionLabel={(option) => option.gene_id}

      filterOptions={x => x}
      onChange={(event, newValue) => {
        setValue(newValue);

      }}
      onInputChange={(event, newInputValue) => {
        event.preventDefault();
        setInputValue(newInputValue);
        fetch("http://localhost:5000/api-v1/gene-aliases?alias_symbol="+newInputValue)
              .then(res => res.json())
              .then(
                (result) => {
                  setIsLoaded(true);
                  setOptions(result);
                  console.log(result);
                },
                // Note: it's important to handle errors here
                // instead of a catch() block so that we don't swallow
                // exceptions from actual bugs in components.
                (error) => {
                  setIsLoaded(true);
                }
              );
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