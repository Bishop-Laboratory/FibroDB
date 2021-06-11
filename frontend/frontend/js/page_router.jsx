import React from 'react';
import {
    BrowserRouter as Router,
    Switch,
    Route,
    Link
  } from "react-router-dom";
  import {Menu} from './components/pageview.jsx';


  export default function App() {
    return (
      <Router>
        <div>
          <nav>
            <Menu>
              <div>
                <Link to="/">Home</Link>
              </div>
              <div>
                <Link to="/search-genes">Search-Genes</Link>
              </div>
              <div>
                <Link to="/about">About</Link>
              </div>
            </Menu>
          </nav>
  
          <Switch>
            <Route exact path="/">
              <Home />
            </Route>
            <Route path="/search-genes">
              <Search />
            </Route>
            <Route path="/about">
              <About />
            </Route>
          </Switch>
        </div>
      </Router>
    );
  }
  
  function Home() {
    return <h2>Home</h2>;
  }
  
  function About() {
    return <h2>About</h2>;
  }
  
  function Search() {
    return <h2>Search</h2>;
  }