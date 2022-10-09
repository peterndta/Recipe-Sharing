import React, { useState } from 'react'

import queryString from 'query-string'
import { useHistory, useLocation } from 'react-router-dom'
import { useRecoilValue } from 'recoil'

import {
    Box,
    Button,
    Divider,
    FormControl,
    Grid,
    InputLabel,
    OutlinedInput,
    Typography,
} from '@mui/material'
import { blueGrey, grey } from '@mui/material/colors'

import continentAtom from '../../../../recoil/continents'
import ContinentsFilter from './Continents'

const Filter = () => {
    const continentsList = useRecoilValue(continentAtom)
    const { search: query, pathname } = useLocation()

    const { q } = queryString.parse(query)
    const history = useHistory('')
    const [continents, setContinents] = React.useState([])
    const [searchValue, setSearchValue] = useState(q ? q : '')

    const selectHandler = (value, type) => () => {
        if (continentsList.type === type) {
            const currentIndex = continents.indexOf(value)
            const newContinents = [...continents]
            if (currentIndex === -1) {
                newContinents.push(value)
            } else {
                newContinents.splice(currentIndex, 1)
            }
            setContinents(newContinents)
        }
    }

    const searchChangeHandler = (event) => {
        const searchText = event.target.value.trim()
        if (searchText !== '') {
            setSearchValue(event.target.value)
        }
    }

    const searchSubmitHandler = () => {
        if (searchValue.trim().length !== 0) {
            history.push(`/recipes?q=${searchValue}`)
        }
    }

    return (
        <Grid item md={3}>
            <Box p={3} sx={{ border: `1px solid ${blueGrey[200]}`, borderRadius: 1 }}>
                <Box
                    display="flex"
                    justifyContent="space-between"
                    alignItems="center"
                    pb={1}
                    sx={{ borderBottom: (theme) => `3px solid ${theme.palette.primary.main}` }}
                >
                    <Typography variant="h4" fontWeight={700} sx={{ color: blueGrey[800] }}>
                        Filters
                    </Typography>
                    <Button variant="outlined">Clear all</Button>
                </Box>
                <Box mt={3} mb={1}>
                    <Typography variant="h6" fontWeight={700} sx={{ color: blueGrey[800] }} mb={2}>
                        Recipe or keyword
                    </Typography>

                    <FormControl
                        sx={{
                            width: '100%',
                            '& label.Mui-focused': {
                                color: blueGrey[800],
                            },
                            '& .css-1xnpwac-MuiInputBase-root-MuiOutlinedInput-root.Mui-focused .MuiOutlinedInput-notchedOutline':
                                {
                                    borderColor: blueGrey[800],
                                },
                            '& .MuiOutlinedInput-input': {
                                height: '0.8em',
                            },
                        }}
                    >
                        <InputLabel htmlFor="component-outlined" sx={{ top: -5 }}>
                            Keyword
                        </InputLabel>
                        <OutlinedInput
                            id="component-outlined"
                            label="Keyword"
                            value={searchValue}
                            onChange={searchChangeHandler}
                        />
                    </FormControl>
                </Box>
                <Divider
                    sx={{
                        backgroundColor: (theme) => theme.palette.primary.main,
                        height: 2,
                        mt: 2,
                    }}
                />
                <ContinentsFilter
                    continents={continentsList}
                    checks={continents}
                    selectHandler={selectHandler}
                />
                <Box width="100%" display="flex" justifyContent="center" mt={3}>
                    <Button
                        variant="contained"
                        sx={{ color: grey[100] }}
                        onClick={searchSubmitHandler}
                    >
                        SHOW RESULTS
                    </Button>
                </Box>
            </Box>
        </Grid>
    )
}

export default Filter
