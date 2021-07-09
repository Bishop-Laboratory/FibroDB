import Plot from 'react-plotly.js';
import React, { useState, useEffect } from 'react';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
    formControl: {
      margin: theme.spacing(1),
      minWidth: 120,
    },
    selectEmpty: {
      marginTop: theme.spacing(2),
    },
  }));
  


export default function GenePlot(genename) {
    const classes = useStyles();  
  const [localData, setData] = useState({});
  const [isLoaded, setIsLoaded] = useState(false);
  const [yChoice, setY] = useState('cpm');
  const [open, setOpen] = React.useState(false);  

  const handleChange = (event) => {
    setY(event.target.value);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const handleOpen = () => {
    setOpen(true);
  };


  genename = genename["genename"];

  useEffect(() => {
    fetch("http://localhost:5000/api-v1/expression?gene_id="+genename)
      .then(res => res.json())
      .then(
        (result) => {
          setIsLoaded(true);
          console.log("Got Data");
          console.log(result);

          const result2 = {
            'cpm': result.map(elem => elem['cpm']),
            'rpkm': result.map(elem => elem['rpkm']),
            'tpm': result.map(elem => elem['tpm']),
            'gene_id': result.map(elem => elem['gene_id']),
            'sample_id': result.map(elem => elem['sample_id'])
          }
          console.log(result2);
          setData(result2);
        },
        (error) => {
          setIsLoaded(true);
          console.log(error);
        }
      )
  }, []);

  return <div>
    {isLoaded ? <div>
        
        <FormControl className={classes.formControl}>
        <InputLabel>Count Type</InputLabel>
        <Select
        labelId="demo-simple-select-label"
        id="demo-simple-select"
          open={open}
          onClose={handleClose}
          onOpen={handleOpen}
          value={yChoice}
          onChange={handleChange}
        >
          <MenuItem value="cpm">
            cpm
          </MenuItem>
          <MenuItem value="rpkm">rpkm</MenuItem>
          <MenuItem value="tpm">tpm</MenuItem>
        </Select>
      </FormControl>
        <Plot
      data={[
        {
          x: localData.sample_id,
          y: localData[yChoice],
          type: 'scatter',
          mode: 'markers',
          marker: { color: 'red' },
        },
      ]}
      layout={{ width: 1000, height: 300, title: 'Gene Plot for '+genename, yaxis:{title:yChoice}}}
      /></div> : <h1>Loading...</h1>}
  </div>
}
