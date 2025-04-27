import React, { useEffect, useState, useMemo } from "react";
import {
    Table, Button, Form, Badge, Spinner, Row, Col, Card, InputGroup,
    FormControl
} from "react-bootstrap";
import { projectServices } from "../../services/projectService";
import { useAuth } from "../../providers/AuthProvider";
import { toast } from "react-toastify";
import { format, subDays, startOfMonth } from "date-fns";

const ProjectList = () => {
    const { user } = useAuth();
    const [allProjects, setAllProjects] = useState([]);
    const [projects, setProjects] = useState([]);
    const [loading, setLoading] = useState(false);
    const [filters, setFilters] = useState({
        status: "all",
        dateRange: "all",
        search: ""
    });
    const [sortConfig, setSortConfig] = useState({ key: null, direction: "asc" });

    useEffect(() => {
        fetchProjects();
    }, []);

    const fetchProjects = async () => {
        setLoading(true);
        try {
            const result = await projectServices.fetchProjects(localStorage.getItem("authToken"));
            console.log('User Project List', result);
            if (result.success && result.data?.projects) {
                const userProjects = result.data.projects.filter(
                    project => project.submittedBy?.id === user?.id
                );
                setAllProjects(userProjects);
            } else {
                throw new Error(result.message || "Failed to load projects.");
            }
        } catch (error) {
            console.error("Error fetching projects:", error);
            toast.error("Failed to load projects!");
        }
        setLoading(false);
    };

    const filteredProjects = useMemo(() => {
        return allProjects.filter(project => {
            const statusMatch = filters.status === "all" || project.status.toLowerCase() === filters.status;

            let dateMatch = true;
            const now = new Date();

            if (filters.dateRange === "last7days") {
                const sevenDaysAgo = subDays(now, 7);
                dateMatch = new Date(project.submissionDate) >= sevenDaysAgo && new Date(project.submissionDate) <= now;
            } else if (filters.dateRange === "last30days") {
                const thirtyDaysAgo = subDays(now, 30);
                dateMatch = new Date(project.submissionDate) >= thirtyDaysAgo && new Date(project.submissionDate) <= now;
            } else if (filters.dateRange === "thisMonth") {
                const startOfCurrentMonth = startOfMonth(now);
                dateMatch = new Date(project.submissionDate) >= startOfCurrentMonth && new Date(project.submissionDate) <= now;
            }

            const searchMatch = filters.search
                ? project.title.toLowerCase().includes(filters.search.toLowerCase()) ||
                project.submittedBy?.name?.toLowerCase().includes(filters.search.toLowerCase())
                : true;

            return statusMatch && dateMatch && searchMatch;
        });
    }, [allProjects, filters]);

    useEffect(() => {
        setProjects(filteredProjects);
    }, [filteredProjects]);


    const sortTable = (key) => {
        const direction = sortConfig.key === key && sortConfig.direction === "asc" ? "desc" : "asc";
        setSortConfig({ key, direction });

        const sortedProjects = [...projects].sort((a, b) => {
            const valueA = a[key]?.toLowerCase?.() ?? "";
            const valueB = b[key]?.toLowerCase?.() ?? "";

            if (key.includes('Date') || key === 'lastUpdated') {
                return direction === "asc"
                    ? new Date(a[key]) - new Date(b[key])
                    : new Date(b[key]) - new Date(a[key]);
            }

            return direction === "asc"
                ? valueA.localeCompare(valueB)
                : valueB.localeCompare(valueA);
        });

        setProjects(sortedProjects);
    };

    const getStatusColor = (status) => {
        switch (status.toLowerCase()) {
            case "approved":
                return "success";
            case "rejected":
                return "danger";
            case "pending":
                return "warning";
            default:
                return "secondary";
        }
    };

    const handleFilterChange = (name, value) => {
        setFilters(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const resetFilters = () => {
        setFilters({
            status: "all",
            dateRange: "all",
            search: ""
        });
    };

    return (
        <div className="container py-4">
            <h2 className="mb-4">Project List</h2>
            <Card className="mb-4 shadow-sm">
                <Card.Body>
                    <h5 className="mb-3">Filters</h5>
                    <Row className="g-3">
                        <Col md={4}>
                            <Form.Group controlId="statusFilter">
                                <Form.Label>Status</Form.Label>
                                <Form.Select
                                    value={filters.status}
                                    onChange={(e) => handleFilterChange("status", e.target.value)}
                                >
                                    <option value="all">All Statuses</option>
                                    <option value="approved">Approved</option>
                                    <option value="rejected">Rejected</option>
                                    <option value="pending">Pending</option>
                                </Form.Select>
                            </Form.Group>
                        </Col>

                        <Col md={4}>
                            <Form.Group controlId="dateFilter">
                                <Form.Label>Date Range</Form.Label>
                                <Form.Select
                                    value={filters.dateRange}
                                    onChange={(e) => handleFilterChange("dateRange", e.target.value)}
                                >
                                    <option value="all">All Time</option>
                                    <option value="last7days">Last 7 Days</option>
                                    <option value="last30days">Last 30 Days</option>
                                    <option value="thisMonth">This Month</option>
                                </Form.Select>
                            </Form.Group>
                        </Col>

                        <Col md={4}>
                            <Form.Group controlId="searchFilter">
                                <Form.Label>Search</Form.Label>
                                <InputGroup>
                                    <FormControl
                                        placeholder="Search projects..."
                                        value={filters.search}
                                        onChange={(e) => handleFilterChange("search", e.target.value)}
                                    />
                                    <Button
                                        variant="outline-secondary"
                                        onClick={resetFilters}
                                    >
                                        Reset
                                    </Button>
                                </InputGroup>
                            </Form.Group>
                        </Col>
                    </Row>
                </Card.Body>
            </Card>

            {loading ? (
                <div className="text-center py-5">
                    <Spinner animation="border" variant="primary" />
                    <p className="mt-2">Loading projects...</p>
                </div>
            ) : (
                <Card className="shadow-sm border-0">
                    <Card.Body className="p-0">
                        <div className="table-responsive">
                            <Table striped bordered hover className="mb-0">
                                <thead className="bg-light">
                                    <tr>
                                        {["title", "submittedBy", "submissionDate", "status", "lastUpdated"].map((key) => (
                                            <th
                                                key={key}
                                                onClick={() => sortTable(key)}
                                                style={{ cursor: "pointer", minWidth: "150px" }}
                                                className="py-3"
                                            >
                                                <div className="d-flex align-items-center">
                                                    {key.charAt(0).toUpperCase() + key.slice(1).replace(/([A-Z])/g, ' $1')}
                                                    {sortConfig.key === key && (
                                                        <i
                                                            className={`bi bi-caret-${sortConfig.direction === "asc" ? "up" : "down"}-fill ms-2`}
                                                        />
                                                    )}
                                                </div>
                                            </th>
                                        ))}
                                    </tr>
                                </thead>
                                <tbody>
                                    {projects.length > 0 ? (
                                        projects.map((project) => (
                                            <tr key={project.id}>
                                                <td className="align-middle">{project.title}</td>
                                                <td className="align-middle">{project.submittedBy?.name || 'N/A'}</td>
                                                <td className="align-middle">
                                                    {format(new Date(project.submissionDate), 'MMM dd,')}
                                                </td>
                                                <td className="align-middle">
                                                    <Badge pill bg={getStatusColor(project.status)} className="px-3 py-2">
                                                        {project.status}
                                                    </Badge>
                                                </td>
                                                <td className="align-middle">
                                                    {format(new Date(project.lastUpdated), 'MMM dd, HH:mm')}
                                                </td>
                                            </tr>
                                        ))
                                    ) : (
                                        <tr>
                                            <td colSpan={5} className="text-center py-4">
                                                No projects found matching your criteria
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </Table>
                        </div>
                    </Card.Body>
                </Card>
            )}
        </div>
    );
};

export default ProjectList;
