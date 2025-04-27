import { useEffect, useState, useCallback } from "react";
import { projectServices } from "../services/projectService";
import { toast } from "react-toastify";
import { useNavigate } from "react-router-dom";

export const useProjectData = () => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const navigate = useNavigate();

    const getAuthToken = useCallback(() => {
        const token = localStorage.getItem("authToken");
        if (!token) {
            const msg = "Authentication token not found. Please log in.";
            toast.error(msg);
            setError(msg);
            setLoading(false);
            return null;
        }
        return token;
    }, []);

    const loadProjectData = useCallback(async () => {
        setLoading(true);
        setError(null);

        const token = getAuthToken();
        if (!token) return;

        try {
            const result = await projectServices.fetchProjects(token);
            if (result.success) {
                setData(result.data);
            } else {
                throw new Error(result.message || "Something went wrong");
            }
        } catch (err) {
            toast.error(err.message);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }, [getAuthToken]);

    useEffect(() => {
        loadProjectData();
    }, [loadProjectData]);

    const createProject = async (formData) => {
        setLoading(true);
        setError(null);

        const token = getAuthToken();
        if (!token) return;

        try {
            const result = await projectServices.createProject(token, formData);
            if (result.success) {
                toast.success("Project created successfully!");
                navigate("/user/projects");
                return result.data;
            } else {
                throw new Error(result.message || "Failed to create project");
            }
        } catch (err) {
            toast.error(err.message);
            setError(err.message);
            return null;
        } finally {
            setLoading(false);
        }
    };

    return { data, loading, error, createProject };
};
