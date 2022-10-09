import React from 'react'

import { Box, Card, CardContent, CardMedia, Grid, Rating, Typography } from '@mui/material'
import { grey } from '@mui/material/colors'

const LatestRecipe = ({ post }) => {
    return (
        <Grid item md={4}>
            <Card sx={{ maxWidth: 392 }}>
                <CardMedia component="img" alt="green iguana" height="270" image={post.image} />
                <CardContent>
                    <Typography gutterBottom variant="h5" component="div" fontWeight={700}>
                        {post.name}
                    </Typography>
                    <Typography variant="body1" color="text.secondary">
                        {post.description}
                    </Typography>
                    <Rating
                        name="half-rating-read"
                        value={post.rating}
                        precision={0.5}
                        readOnly
                        sx={{ mt: 2 }}
                    />
                    <Box mt={1}>
                        <Typography component="span" sx={{ color: grey[500] }}>
                            By
                        </Typography>
                        <Typography component="span" ml={1.5} variant="body2" fontWeight={700}>
                            {post.author}
                        </Typography>
                    </Box>
                </CardContent>
            </Card>
        </Grid>
    )
}

export default LatestRecipe
