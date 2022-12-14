import React, { useState } from 'react'

import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    BarElement,
    Title,
    Tooltip,
    Legend,
} from 'chart.js'
import { Bar } from 'react-chartjs-2'

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend)

const VerticalBar = ({ userTopRate }) => {
    const [userMostPost, setUserMostPost] = useState({
        labels: userTopRate.map((data) => data.name),
        datasets: [
            {
                label: 'Rating',
                data: userTopRate.map((data) => data.average),
                borderColor: [
                    'rgb(255, 99, 132)',
                    'rgb(255, 159, 64)',
                    'rgb(255, 205, 86)',
                    'rgb(75, 192, 192)',
                    'rgb(54, 162, 235)',
                    'rgb(153, 102, 255)',
                    'rgb(201, 203, 207)',
                ],
                backgroundColor: [
                    'rgba(255, 99, 132, 0.2)',
                    'rgba(255, 159, 64, 0.2)',
                    'rgba(255, 205, 86, 0.2)',
                    'rgba(75, 192, 192, 0.2)',
                    'rgba(54, 162, 235, 0.2)',
                    'rgba(153, 102, 255, 0.2)',
                    'rgba(201, 203, 207, 0.2)',
                ],
                barPercentage: 0.6,
            },
        ],
    })
    return (
        <React.Fragment>
            <Bar
                data={userMostPost}
                options={{
                    indexAxis: 'x',
                    elements: {
                        bar: {
                            borderWidth: 2,
                        },
                    },
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false,
                        },
                        title: {
                            display: true,
                            text: 'Top 5 Accounts with High Ratings',
                        },
                    },
                    scales: {
                        xAxis: {
                            ticks: {
                                callback: function (value) {
                                    if (this.getLabelForValue(value).length > 6) {
                                        return this.getLabelForValue(value).substr(0, 6) + '...'
                                    } else {
                                        return this.getLabelForValue(value)
                                    }
                                },
                            },
                            barThickness: 0.1,
                        },
                    },
                }}
            />
        </React.Fragment>
    )
}

export default VerticalBar
