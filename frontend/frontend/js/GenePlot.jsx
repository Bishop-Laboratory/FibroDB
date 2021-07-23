import Plot from 'react-plotly.js';
import React, { useState, useEffect } from 'react';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Checkbox from '@material-ui/core/Checkbox';
import ListItemText from '@material-ui/core/ListItemText';
import Select from '@material-ui/core/Select';
import { makeStyles } from '@material-ui/core/styles';
import { SERVER_BASE } from './constants';

const useStyles = makeStyles((theme) => ({
    formControl: {
      margin: theme.spacing(1),
      minWidth: 120,
    },
    selectEmpty: {
      marginTop: theme.spacing(2),
    },
  }));
  

export const GenericForm = ({inputLabel, forminputs, handleFormChange, isMulti}) => {
  const classes = useStyles();  
  const [open, setOpen] = useState(false);
  const [localState, setLocal] = useState('');
  const [localArray, setArray] = useState(forminputs);
  const handleOpen = () => {
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const handleChange = (event) => {
    handleFormChange(event.target.value);
    if(isMulti) {
      setArray(event.target.value);
    }
    else{
    setLocal(event.target.value);
    }
  };


return <FormControl className={classes.formControl}>
<InputLabel>{inputLabel}</InputLabel>
{isMulti?
<Select
  labelId="demo-mutiple-checkbox-label"
  id="demo-mutiple-checkbox"
  multiple
  open={open}
  onClose={handleClose}
  onOpen={handleOpen}
  value={localArray}
  onChange={handleChange}
  renderValue={(selected) => selected.join(', ')}
>    
 {forminputs.map((elem) => <MenuItem value={elem} key={elem}>
 <Checkbox checked={localArray.indexOf(elem) > -1} />
 <ListItemText primary={elem} />
   
   </MenuItem>)}
</Select>
:
<Select
labelId="demo-simple-select-label"
id="demo-simple-select"

  open={open}
  onClose={handleClose}
  onOpen={handleOpen}
  value={localState}
  onChange={handleChange}
>
      
 {forminputs.map((elem) => <MenuItem value={elem} key={elem}>{elem}</MenuItem>)}
</Select>
}

</FormControl>

  
}


export default function GenePlot(genename) {
  const [localData, setData] = useState({});
  const [localStudies, setStudies] = useState([]);
  const [isLoaded, setIsLoaded] = useState(false);
  const [yChoice, setY] = useState('cpm');
  const [studiesChoice, setChoice] = useState([]);




  genename = genename["genename"];
  useEffect(() => {
    fetch(SERVER_BASE + "expression?gene_id="+genename)
      .then(res => res.json())
      .then(
        (result) => {
          

          const result2 = {
            'cpm': result.map(elem => elem['cpm']),
            'rpkm': result.map(elem => elem['rpkm']),
            'tpm': result.map(elem => elem['tpm']),
            'gene_id': result.map(elem => elem['gene_id']),
            'sample_id': result.map(elem => elem['sample_id'])
          }
          result2["study_id"] = [];
          fetch(SERVER_BASE + "samples")
            .then(res => res.json())
            .then(
              (result) => {
                for (let i = 0; i <  result2['sample_id'].length; i++) {
                  for (let j = 0; j < result.length; j++) {
                    if(result2['sample_id'][i] == result[j]["sample_id"]) {
                      result2["study_id"].push(result[j]["study_id"]);
                    }
                  }
                }
                setStudies(result2["study_id"]);
                setChoice(localStudies.filter((v, i, a) => a.indexOf(v) === i));
              }
        ,()=>{});
        setData(result2);
        setIsLoaded(true);
            },
        (error) => {
          setIsLoaded(true);
          console.log(error);
        }
      )
  }, []);

  return <div>
    {console.log(studiesChoice.length === 0, studiesChoice === [])}
    {isLoaded ? <div>
        <GenericForm isMulti={false} inputLabel="Count Type" forminputs={["cpm", "tpm", "rpkm"]} handleFormChange={setY} />
        <GenericForm isMulti={true} inputLabel="Studies" forminputs={localStudies.filter((v, i, a) => a.indexOf(v) === i)} handleFormChange={setChoice} />
        <Plot
      data={[
        {
          x: localData.sample_id.filter((elem, index) =>  studiesChoice.includes(localStudies[index])),
          y: localData[yChoice].filter((elem, index) =>  studiesChoice.includes(localStudies[index])),
          type: 'scatter',
          mode: 'markers',
          marker: { color: 'red' },
        },
      ]}
      layout={{ width: 1000, height: 300, title: 'Gene Plot for '+genename, yaxis:{title:yChoice}}}
      />
      </div> : <h1>Loading...</h1>}
  </div>
}
