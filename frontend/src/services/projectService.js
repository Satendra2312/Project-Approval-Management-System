import axios from "axios";

const API_BASE_URL = "/api";

const getAuthHeaders = (token) => ({
    Authorization: `Bearer ${token || localStorage.getItem("authToken")}`,
    "Content-Type": "application/json",
});

const axiosInstance = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        "Content-Type": "application/json",
    },
});

// Centralized error handler
const handleError = (error, defaultMessage) => {
    console.error(defaultMessage, error.response?.data || error.message);
    return {
        success: false,
        message: error.response?.data?.message || defaultMessage,
    };
};

export const projectServices = {
    async fetchProjects(token) {
        try {
            const response = await axiosInstance.get("/projects", {
                headers: getAuthHeaders(token),
            });
            return { success: true, data: response.data };
        } catch (error) {
            return handleError(error, "Failed to fetch projects");
        }
    },

    async createProject(token, formData) {
        try {
            const response = await axiosInstance.post("/projects", formData, {
                headers: {
                    ...getAuthHeaders(token),
                    "Content-Type": "multipart/form-data",
                },
            });
            return { success: true, data: response.data };
        } catch (error) {
            return handleError(error, "Failed to create project");
        }
    },

    async updateProjectStatus(projectId, action, reason = "") {
        try {
            const response = await axiosInstance.patch(`/projects/${projectId}/${action}`, { reason }, {
                headers: getAuthHeaders(),
            });
            return { success: true, data: response.data };
        } catch (error) {
            return handleError(error, `Failed to ${action} project`);
        }
    },
};
