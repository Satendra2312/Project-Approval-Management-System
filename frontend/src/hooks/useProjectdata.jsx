// useProjectdata.jsx
import { useEffect, useState } from 'react';
import { projectServices } from '../services/projectService';
import { toast } from 'react-toastify';

export const useProjectData = () => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const loadProjectData = async () => {
        setLoading(true);
        setError(null);

        const token = localStorage.getItem('authToken');
        if (!token) {
            const msg = "Authentication token not found. Please log in.";
            toast.error(msg);
            setError(msg);
            setLoading(false);
            return;
        }

        try {
            const result = await projectServices.fetchProjects(token); // Correct usage
            if (result.success) {
                setData({
                    data: result.data,
                });
                console.log('Projects', result.data);
            } else {
                throw new Error(result.message || 'Something went wrong');
            }
        } catch (err) {
            toast.error(err.message);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadProjectData();
    }, []);

    return { data, loading, error };
};