import React from 'react'

import NumberItemPagination from '../../../../../components/NumberItemPagination'
import { Add, Search } from '@mui/icons-material'
import {
    Box,
    Button,
    IconButton,
    FormControl,
    InputBase,
    InputLabel,
    MenuItem,
    Pagination,
    Select,
} from '@mui/material'
import { blueGrey, grey } from '@mui/material/colors'

import { MOST_FAVORITE_POSTS } from '../../../../../Elixir'
import AddCollectionPopup from '../AddCollectionPopup'
import PostLists from './PostLists'

const PostList = () => {
    const [open, setOpen] = React.useState(false)
    const [type, setType] = React.useState('')

    const handleChange = (event) => {
        setType(event.target.value)
    }
    const handleClickOpen = () => {
        setOpen(true)
    }
    return (
        <React.Fragment>
            {open && <AddCollectionPopup status={open} onClose={() => setOpen(false)} />}
            <Button
                variant="outlined"
                sx={{ color: grey[700], width: 200, mb: 2, minWidth: 100, alignSelf: 'flex-end' }}
                startIcon={<Add />}
                onClick={handleClickOpen}
            >
                CREATE COLLECTION
            </Button>
            <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box
                    component="form"
                    sx={{
                        p: 0.5,
                        display: 'flex',
                        alignItems: 'center',
                        width: 400,
                        border: `1px solid ${blueGrey[200]}`,
                        borderRadius: 0.5,
                    }}
                >
                    <IconButton type="button" sx={{ p: '10px' }} aria-label="search">
                        <Search />
                    </IconButton>
                    <InputBase
                        sx={{ ml: 1, flex: 1 }}
                        placeholder="Search recipe name"
                        inputProps={{ 'aria-label': 'search recipe name' }}
                    />
                </Box>
                <FormControl sx={{ minWidth: 100, alignSelf: 'flex-end' }} size="medium">
                    <InputLabel id="demo-select-small">Type</InputLabel>
                    <Select
                        labelId="demo-select-small"
                        id="demo-select-small"
                        value={type}
                        label="Sort"
                        onChange={handleChange}
                    >
                        <MenuItem value={'popularity'}>Popularity</MenuItem>
                        <MenuItem value={'newest'}>Newest</MenuItem>
                        <MenuItem value={'oldest'}>Oldest</MenuItem>
                    </Select>
                </FormControl>
            </Box>
            <NumberItemPagination from={1} to={6} all={15} />
            <PostLists posts={MOST_FAVORITE_POSTS} />
            <Pagination count={10} variant="outlined" sx={{ alignSelf: 'center', mt: 6 }} />
        </React.Fragment>
    )
}

export default PostList