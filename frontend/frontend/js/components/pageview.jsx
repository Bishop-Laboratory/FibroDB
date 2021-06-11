import styled from 'styled-components'

export const Menu = styled.div`
    background-color: LightSkyBlue;
    display: flex;
    flex-direction: row;
    width: 100%;
    justify-content: space-around;
    div {
        width: 30%;
        box-sizing: border-box;
        padding: 1em;
        margin: auto;
        a {
        margin: auto;
        text-align: center;
        color: white;
        display: block;
        }
    }
`