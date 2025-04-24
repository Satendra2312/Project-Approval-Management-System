import axios from 'axios';

const API_BASE_URL = '/api';

export const authService = {
    async login(credentials) {
        try {
            const response = await axios.post(`${API_BASE_URL}/login`, credentials);
            return { success: true, data: response.data, message: response.data.message || 'Login successful' };
        } catch (error) {
            console.error('Login API Error:', error.response?.data || error.message);
            return { success: false, message: error.response?.data?.error || 'Login failed. Please try again.' };
        }
    },

    async register(userData) {
        try {
            const response = await axios.post(`${API_BASE_URL}/register`, userData);
            return { success: true, data: response.data, message: response.data.message || 'Registration successful' };
        } catch (error) {
            return { success: false, message: error.response?.data?.error || 'Registration failed. Please try again.' };
        }
    },

    async logout() {
        const token = localStorage.getItem('authToken');
        if (token) {
            try {
                await axios.post(`${API_BASE_URL}/logout`, {}, {
                    headers: { Authorization: `Bearer ${token}` },
                });
                return { success: true, message: 'Logout successful' };
            } catch (error) {
                return { success: false, message: 'Logout failed. Please try again.' };
            }
        }
        return { success: true, message: 'No active session' };
    },

    async getAuthenticatedUser() {
        const token = localStorage.getItem('authToken');
        if (token) {
            try {
                const response = await axios.get(`${API_BASE_URL}/user`, {
                    headers: { Authorization: `Bearer ${token}` },
                });
                return { success: true, data: response.data, message: 'User data retrieved successfully' };
            } catch (error) {
                return { success: false, message: error.response?.data?.error || 'Failed to retrieve user data.' };
            }
        }
        return { success: false, message: 'No token found' };
    },
};
