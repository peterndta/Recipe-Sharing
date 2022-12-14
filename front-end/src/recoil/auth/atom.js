import { atom } from 'recoil'

const authAtom = atom({
    key: 'authAtom',
    default: { token: null, email: '', name: '', image: '', role: '', exp: 0, userId: null },
})

export default authAtom
