import React from "react";
import { Container, Row, Col } from "react-bootstrap";
import ProjectForm from "../../components/common/ProjectForm";
import { useProjectData } from "../../hooks/useProjectData";

const CreateProject = () => {
    const { createProject } = useProjectData();

    return (
        <Container>
            <Row className="justify-content-md-center">
                <Col md={6}>
                    <h2 className="text-center mb-4">Create New Project</h2>
                    <ProjectForm onSubmit={createProject} />
                </Col>
            </Row>
        </Container>
    );
};

export default CreateProject;
