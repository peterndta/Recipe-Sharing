import React, { useEffect, useState } from 'react'

import queryString from 'query-string'
import { useLocation } from 'react-router-dom'

import NumberItemPagination from '../../../components/NumberItemPagination'
import { Box } from '@mui/material'

import { useSnackbar } from '../../../HOCs/SnackbarContext'
import useMyBookmarks from '../../../recoil/my-bookmarks/action'
import Loading from '../../Loading'
import Paging from '../BookmarkList/Pagination'
import Bookmarks from './Bookmarks'
import SearchBox from './Search'
import Sort from './Sort'

const filterStringGenerator = ({ search, sort }) => {
    let filterString = `?PageSize=${6}`

    if (search && search.trim() !== '') filterString += '&search=' + search

    if (sort !== undefined) filterString += `&sort=${sort}`

    return filterString
}

const BookmarkList = () => {
    const { search: query } = useLocation()
    const { search, sort, pageNum } = queryString.parse(query)
    const getBookmarkPostsAction = useMyBookmarks()
    const [recipes, setRecipes] = useState({ list: [], pageCount: 1 })
    const showSnackBar = useSnackbar()
    const [isLoading, setIsLoading] = useState(false)

    useEffect(() => {
        const params = filterStringGenerator({ search, sort })
        setIsLoading(true)

        if (pageNum === undefined) {
            getBookmarkPostsAction
                .getMyBookmarkPosts(params)
                .then((res) => {
                    const listRecipe = res.data.data
                    const { totalPages } = res.data.meta
                    setRecipes({ list: listRecipe, pageCount: totalPages })
                    setTimeout(() => {
                        setIsLoading(false)
                    }, 500)
                })
                .catch(() => {
                    showSnackBar({
                        severity: 'error',
                        children: 'Something went wrong, please try again later.',
                    })
                    setTimeout(() => {
                        setIsLoading(false)
                    }, 500)
                })
        } else {
            getBookmarkPostsAction
                .getMyBookmarkPosts(params, pageNum)
                .then((res) => {
                    const listRecipe = res.data.data
                    const { totalPages } = res.data.meta
                    setRecipes({ list: listRecipe, pageCount: totalPages })
                    setTimeout(() => {
                        setIsLoading(false)
                    }, 500)
                })
                .catch(() => {
                    showSnackBar({
                        severity: 'error',
                        children: 'Something went wrong, please try again later.',
                    })
                    setTimeout(() => {
                        setIsLoading(false)
                    }, 500)
                })
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [search, sort, pageNum])
    return (
        <React.Fragment>
            {isLoading ? (
                <Loading />
            ) : (
                <React.Fragment>
                    <Box display="flex" justifyContent="space-between" alignItems="center">
                        <SearchBox />
                        <Sort />
                    </Box>
                    <NumberItemPagination from={1} to={6} all={15} />
                    <Bookmarks posts={recipes.list} />
                    {recipes.pageCount !== 1 && <Paging size={recipes.pageCount} />}
                </React.Fragment>
            )}
        </React.Fragment>
    )
}

export default BookmarkList
