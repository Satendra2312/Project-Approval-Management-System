import axios from 'axios';

const API_BASE_URL = '/api';

export const projectServices = {

    async fetchProjects(token) {
        try {
            const response = await axios.get(`${API_BASE_URL}/projects`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                    'Content-Type': 'application/json',
                },
            });

            const data = response.data;
            return {
                success: true,
                data: data,
            };
        } catch (error) {
            console.error('Dashboard API Error:', error.response?.data || error.message);
            return {
                success: false,
                message: error.response?.data?.message || error.message || 'Failed to fetch project dashboard data',
            };
        }
    },

};
