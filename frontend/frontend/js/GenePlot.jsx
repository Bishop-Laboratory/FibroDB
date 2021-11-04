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
  


export const GenericForm = ({inputLabel, forminputs, handleFormChange, isMulti, defaultVal}) => {
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
  defaultValue={forminputs}
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


export const GenePlotSet = ({genename}) =>  {
  const [localData, setData] = useState([]);

  useEffect(() => {
    fetch(SERVER_BASE + "gene-info?gene_symbol="+genename)
    .then(res => res.json())
    .then((result) => {
      let localArray = [];
      for(let i = 0; i < result.length; i++) {
        console.log("Fetching Data", result[i]);
        localArray.push(result[i]["gene_id"]);
      }
      setData(localArray);
    })
  }, []);
  return <div>
    {
      localData.map((elem) => <GenePlot key={elem} genename={elem} displayname={genename}/>)
    }
  </div>
}


export default function GenePlot({genename, displayname}) {
 
  const [localData, setData] = useState({});
  const [localStudies, setStudies] = useState([]);
  const [isLoaded, setIsLoaded] = useState(false);
  const [yChoice, setY] = useState('cpm');
  const [studiesChoice, setChoice] = useState([]);
  const [xlabels, setLabels] = useState([]);
  const [Groups, setGroups] = useState([]);

  const studies2 = ["GSE149413", "GSE97829", "GSE123018", "GSE140523"];

  const displaynames = ["Transcriptome profile of fibroblasts in chronic thromboembolic pulmonary hypertension", 
                      "RNA-Seq analysis of human lung fibroblasts exposed to TGF-β",
                      "Translational control of cardiac fibrosis (I)",
                      "Tissue specific human fibroblast differential expression based on RNAsequencing analysis"];
  


  useEffect(() => {console.log("genename", genename);}, [genename]);
  useEffect(() => {console.log("studiesChoice", studiesChoice);}, [studiesChoice]);
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
          let labels = [];
          let groups = [];
          fetch(SERVER_BASE + "samples")
            .then(res => res.json())
            .then(
              (result) => {
                for (let i = 0; i <  result2['sample_id'].length; i++) {
                  for (let j = 0; j < result.length; j++) {
                    if(result2['sample_id'][i] == result[j]["sample_id"]) {
                      result2["study_id"].push(result[j]["study_id"]);
                      console.log(result[j]["condition"]+  " replicate " + result[j]["replicate"]);
                      labels.push(result[j]["condition"]+  " replicate " + result[j]["replicate"]);
                      groups.push(result[j]["condition"]);
                    }
                  }
                }
                setLabels(labels);
                setGroups(groups);
                setStudies(result2["study_id"]);
                setChoice(localStudies.filter((v, i, a) => a.indexOf(v) === i));
              }
        ,()=>{});
        setData(result2);
        setIsLoaded(true);
        },
        (error) => {
          setIsLoaded(false);
          console.log(error);
        }
      )
  }, [genename]);

  console.log("Groups",Groups);

  return <div>
    
    {isLoaded ? <div>
        <GenericForm isMulti={false} inputLabel="Count Type" forminputs={["cpm", "tpm", "rpkm"]} handleFormChange={setY} />
        <GenericForm isMulti={true} inputLabel="Studies" forminputs={localStudies.filter((v, i, a) => a.indexOf(v) === i)} handleFormChange={setChoice} />        
        <h1>{'Gene Plot for '+displayname}</h1>
        {studiesChoice.map((choice, idx) => 
        <Plot 
        key={idx}
        data={[
          {
            x: Groups.filter((elem, index) =>  localStudies[index] == choice),
            y: localData[yChoice].filter((elem, index) =>  localStudies[index] == choice),
            type: 'box',
            boxpoints: "all",
            jitter: 0.3,
            mode: 'markers',
            marker: { color: 'red' },
          },
        ]}
        layout={{ width: 1000, height: 300, title: displaynames[studies2.indexOf(choice)], yaxis:{title:yChoice}}}

        />
        )}
      </div> : <h1>Loading...</h1>}
  </div>
}


export function GenePlotRaw({genename, displayname, studiesChoice}) {
 
  const [localData, setData] = useState({});
  const [localStudies, setStudies] = useState([]);
  const [isLoaded, setIsLoaded] = useState(false);
  const [yChoice, setY] = useState('cpm');
  const [xlabels, setLabels] = useState([]);
  const [Groups, setGroups] = useState([]);


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
          let labels = [];
          let groups = [];
          fetch(SERVER_BASE + "samples")
            .then(res => res.json())
            .then(
              (result) => {
                for (let i = 0; i <  result2['sample_id'].length; i++) {
                  for (let j = 0; j < result.length; j++) {
                    if(result2['sample_id'][i] == result[j]["sample_id"]) {
                      result2["study_id"].push(result[j]["study_id"]);
                      console.log(result[j]["condition"]+  " replicate " + result[j]["replicate"]);
                      labels.push(result[j]["condition"]+  " replicate " + result[j]["replicate"]);
                      groups.push(result[j]["condition"]);
                    }
                  }
                }
                setLabels(labels);
                setGroups(groups);
                setStudies(result2["study_id"]);
              }
        ,()=>{});
        setData(result2);
        setIsLoaded(true);
        },
        (error) => {
          setIsLoaded(false);
          console.log(error);
        }
      )
  }, [genename]);


  const studies2 = ["GSE149413", "GSE97829", "GSE123018", "GSE140523"];

  const displaynames = ["Transcriptome profile of fibroblasts in chronic thromboembolic pulmonary hypertension", 
                      "RNA-Seq analysis of human lung fibroblasts exposed to TGF-β",
                      "Translational control of cardiac fibrosis (I)",
                      "Tissue specific human fibroblast differential expression based on RNAsequencing analysis"];
  

  return <div>
    
    {isLoaded  & studiesChoice!= null & genename != "" & typeof genename !== 'undefined' ? <div>
        <GenericForm isMulti={false} inputLabel="Count Type" forminputs={["cpm", "tpm", "rpkm"]} handleFormChange={setY} />      
        <h1>{displayname ? 'Gene Plot for '+displayname : 'Gene Plot for '+ genename}</h1>
        {studiesChoice.map((choice, idx) => 
        localData[yChoice].filter((elem, index) =>  localStudies[index] == choice).length > 0 &&
        <Plot 
        key={idx}
        data={[
          {
            x: Groups.filter((elem, index) =>  localStudies[index] == choice),
            y: localData[yChoice].filter((elem, index) =>  localStudies[index] == choice),
            type: 'box',
            boxpoints: "all",
            jitter: 0.3,
            mode: 'markers',
            marker: { color: 'red' },
          },
        ]}
        layout={{ width: 1000, height: 300, title: displaynames[studies2.indexOf(choice)], yaxis:{title:yChoice}}}

        />
        )}
      </div> : <div></div> }
  </div>
}