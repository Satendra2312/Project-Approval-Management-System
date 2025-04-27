import React, { useEffect, useState } from "react";
import { Form, Button, Spinner } from "react-bootstrap";
import { useForm } from "react-hook-form";
import { toast } from "react-toastify";

const ProjectForm = ({ onSubmit }) => {
    const {
        register,
        handleSubmit,
        formState: { errors },
        reset,
    } = useForm({ mode: "onChange" });

    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleFormSubmit = async (data) => {
        setIsSubmitting(true); // Disable button and trigger animation

        const formData = new FormData();
        formData.append("title", data.title);
        formData.append("description", data.description);
        if (data.file?.[0]) {
            formData.append("file", data.file[0]);
        }

        await onSubmit(formData); // Await submission process
        reset();
        setIsSubmitting(false); // Re-enable button
    };

    useEffect(() => {
        Object.values(errors).forEach((error) => {
            toast.error(error.message, { position: "top-right", autoClose: 3000 });
        });
    }, [errors]);

    return (
        <Form onSubmit={handleSubmit(handleFormSubmit)} noValidate>
            {/* Title Field */}
            <Form.Group className="mb-3" controlId="title">
                <Form.Label>Project Title</Form.Label>
                <Form.Control
                    type="text"
                    placeholder="Enter project title"
                    {...register("title", {
                        required: "Title is required",
                        minLength: { value: 3, message: "At least 3 characters required" },
                        maxLength: { value: 50, message: "Cannot exceed 50 characters" },
                    })}
                    isInvalid={!!errors.title}
                />
                <Form.Control.Feedback type="invalid">
                    {errors.title?.message}
                </Form.Control.Feedback>
            </Form.Group>

            {/* Description Field */}
            <Form.Group className="mb-3" controlId="description">
                <Form.Label>Description</Form.Label>
                <Form.Control
                    as="textarea"
                    rows={4}
                    placeholder="Enter project description"
                    {...register("description", {
                        required: "Description is required",
                        minLength: { value: 10, message: "At least 10 characters required" },
                    })}
                    isInvalid={!!errors.description}
                />
                <Form.Control.Feedback type="invalid">
                    {errors.description?.message}
                </Form.Control.Feedback>
            </Form.Group>

            {/* File Upload */}
            <Form.Group className="mb-3" controlId="file">
                <Form.Label>Upload File</Form.Label>
                <Form.Control
                    type="file"
                    {...register("file", {
                        required: "File is required",
                    })}
                    isInvalid={!!errors.file}
                />
                <Form.Control.Feedback type="invalid">
                    {errors.file?.message}
                </Form.Control.Feedback>
            </Form.Group>

            {/* Submit Button with Animation */}
            <div className="text-center">
                <Button variant="primary" type="submit" disabled={isSubmitting}>
                    {isSubmitting ? (
                        <>
                            <Spinner as="span" animation="border" size="sm" role="status" aria-hidden="true" />
                            &nbsp; Submitting...
                        </>
                    ) : (
                        "Create Project"
                    )}
                </Button>
            </div>
        </Form>
    );
};

export default ProjectForm;
