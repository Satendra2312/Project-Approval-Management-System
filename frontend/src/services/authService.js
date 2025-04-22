import axios from 'axios';

const API_BASE_URL = '/api';
axios.defaults.withCredentials = true;

export const authService = {
    async login(credentials) {
        try {
            const response = await axios.post(`${API_BASE_URL}/login`, credentials);
            console.log('Login API Response Data:', response.data);
            return response;
        } catch (error) {
            console.error('Login API Error:', error);
            throw error;
        }
    },

    async register(userData) {
        return axios.post(`${API_BASE_URL}/register`, userData);
    },

    async logout() {
        const token = localStorage.getItem('authToken');
        if (token) {
            return axios.post(`${API_BASE_URL}/logout`, {}, {
                headers: { Authorization: `Bearer ${token}` },
            });
        }
        return Promise.resolve();
    },

    async getAuthenticatedUser() {
        const token = localStorage.getItem('authToken');
        if (token) {
            return axios.get(`${API_BASE_URL}/user`, {
                headers: { Authorization: `Bearer ${token}` },
            });
        }
        return Promise.reject({ message: 'No token found' });
    },
};

axios.get('/api/test/test-cookie').then(response => {
    console.log(response.data);
}).catch(error => {
    console.error(error);
});