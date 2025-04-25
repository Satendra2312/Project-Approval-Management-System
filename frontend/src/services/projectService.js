import axios from "axios";

const API_BASE_URL = "/api";

export const projectServices = {
    async fetchProjects(token) {
        try {
            const response = await axios.get(`${API_BASE_URL}/projects`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                    "Content-Type": "application/json",
                },
            });

            return { success: true, data: response.data };
        } catch (error) {
            console.error("Error fetching projects:", error.response?.data || error.message);
            return { success: false, message: error.response?.data?.message || "Failed to fetch projects" };
        }
    },

    async updateProjectStatus(projectId, action, reason = "") {
        try {
            const response = await axios.patch(`${API_BASE_URL}/projects/${projectId}/${action}`, { reason }, {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("authToken")}`,
                    "Content-Type": "application/json",
                },
            });

            return { success: true, data: response.data };
        } catch (error) {
            console.error(`Error updating project (${action}):`, error.response?.data || error.message);
            return { success: false, message: error.response?.data?.message || `Failed to ${action} project` };
        }
    },
};
