import jwt_decode from 'jwt-decode'
import { useHistory } from 'react-router-dom'
import { useSetRecoilState } from 'recoil'

import { post } from '../../utils/ApiCaller'
import LocalStorageUtils from '../../utils/LocalStorageUtils'
import notificationAtom, { useNotification } from '../notification'
import authAtom from './atom'

const useAuthAction = () => {
    const history = useHistory()
    const setAuth = useSetRecoilState(authAtom)
    const setNotification = useSetRecoilState(notificationAtom)
    const notificationAction = useNotification()

    const autoLogin = () => {
        const token = LocalStorageUtils.getToken()
        const user = LocalStorageUtils.getUser()

        if (user && typeof user === 'object') {
            if (user?.exp && user?.exp * 1000 > Date.now()) {
                setAuth({
                    token,
                    email: user.email,
                    name: user.name,
                    image: user.image,
                    role: user.role,
                    exp: user.exp,
                    userId: user.userId,
                })
                if (user.role !== 'admin') {
                    notificationAction.getNewNotifications(+user.userId).then((res) => {
                        const newNotifications = res.data.data.newNotification
                        setNotification({
                            notification: newNotifications,
                        })
                    })
                }
            } else {
                logout()
            }
        } else {
            setAuth({
                token: null,
                email: '',
                name: '',
                image: '',
                role: '',
                exp: 0,
                userId: null,
            })
        }
    }

    const login = (token) =>
        post({
            endpoint: '/api/authentication/auth',
            headers: { Authorization: `Bearer ${token}` },
        }).then((response) => {
            if (response?.data?.isSuccess) {
                LocalStorageUtils.setUser(token)
                const { email, name, image, role, exp, userId } = jwt_decode(token)
                setAuth({ token, email, name, image, role, exp, userId: userId })
                if (role === 'admin') {
                    history.push('/admin')
                } else {
                    notificationAction.getNewNotifications(+userId).then((res) => {
                        const newNotifications = res.data.data.newNotification
                        setNotification({
                            notification: newNotifications,
                        })
                        history.push('/')
                    })
                }
            } else {
                throw new Error('Something went wrong')
            }
        })

    const logout = () => {
        LocalStorageUtils.deleteUser()
        setAuth({
            token: null,
            email: '',
            name: '',
            image: '',
            role: '',
            exp: 0,
            userId: null,
        })
        history.push('/login')
    }

    return {
        autoLogin,
        login,
        logout,
    }
}

export default useAuthAction
