import React, { useState } from 'react'

import { useHistory } from 'react-router-dom'

import SearchIcon from '@mui/icons-material/Search'
import { InputBase } from '@mui/material'
import { styled } from '@mui/material/styles'

const SearchCompo = styled('div')(({ theme }) => ({
    position: 'relative',
    borderRadius: theme.shape.borderRadius,
    backgroundColor: theme.palette.common.white,
    marginRight: theme.spacing(2),
    marginLeft: 0,
    width: '100%',
    [theme.breakpoints.up('sm')]: {
        marginLeft: theme.spacing(3),
        width: 'auto',
    },
}))

const SearchIconWrapper = styled('div')(({ theme }) => ({
    padding: theme.spacing(0, 2),
    height: '100%',
    position: 'absolute',
    pointerEvents: 'none',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
}))

const StyledInputBase = styled(InputBase)(({ theme }) => ({
    color: 'inherit',
    '& .MuiInputBase-input': {
        padding: theme.spacing(1, 1, 1, 0),
        paddingLeft: `calc(1em + ${theme.spacing(4)})`,
        transition: theme.transitions.create('width'),
        width: '100%',
        [theme.breakpoints.up('md')]: {
            width: '30ch',
        },
    },
}))

const Search = () => {
    const [value, setValue] = useState('')
    const history = useHistory()

    const changeHandler = (event) => setValue(event.target.value)

    const searchHandler = (event) => {
        if (event.key === 'Enter') {
            if (value.trim().length !== 0) {
                history.push(`/recipes?search=${value}`)
                setValue('')
            }
        }
    }

    return (
        <SearchCompo>
            <SearchIconWrapper>
                <SearchIcon />
            </SearchIconWrapper>
            <StyledInputBase
                placeholder="Find a recipe"
                inputProps={{ 'aria-label': 'search' }}
                value={value}
                onChange={changeHandler}
                onKeyDown={searchHandler}
            />
        </SearchCompo>
    )
}

export default Search
