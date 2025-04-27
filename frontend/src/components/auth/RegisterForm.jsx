import React, { useEffect } from "react";
import { useForm } from "react-hook-form";
import { Button, Form, Spinner, Alert } from "react-bootstrap";

const RegisterForm = ({ onSubmit, loading }) => {
    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
        setFocus,
        setError,
        clearErrors,
        reset,
        watch,
        trigger,
    } = useForm({ mode: "onTouched" });

    const password = watch('password');
    const watchFields = watch();

    useEffect(() => {
        const firstErrorField = Object.keys(errors)[0];
        if (firstErrorField) {
            setFocus(firstErrorField);
        }
    }, [errors, setFocus]);

    useEffect(() => {
        const fieldNames = Object.keys(watchFields);
        fieldNames.forEach((fieldName) => {
            if (watchFields[fieldName] && errors[fieldName]) {
                clearErrors(fieldName);
            }
        });
    }, [watchFields, errors, clearErrors]);

    return (
        <Form onSubmit={handleSubmit(async (formData) => {
            const result = await onSubmit(formData);
            if (result?.success) reset();
            else if (result?.errors) {
                Object.entries(result.errors).forEach(([field, message]) => {
                    setError(field, { type: "server", message });
                });
            }
        })} noValidate>
            {errors.root && <Alert variant="danger">{errors.root.message}</Alert>}

            <Form.Group className="mb-3" controlId="formUsername">
                <Form.Label>Username</Form.Label>
                <Form.Control
                    type="text"
                    placeholder="Enter username"
                    isInvalid={!!errors.username}
                    {...register("name", {
                        required: "Username is required",
                        minLength: { value: 3, message: "Username must be at least 3 characters" },
                        maxLength: { value: 20, message: "Username cannot exceed 20 characters" },
                    })}
                />
                <Form.Control.Feedback type="invalid">
                    {errors.username?.message}
                </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3" controlId="formEmail">
                <Form.Label>Email address</Form.Label>
                <Form.Control
                    type="email"
                    placeholder="Enter email"
                    isInvalid={!!errors.email}
                    {...register("email", {
                        required: "Email is required",
                        pattern: {
                            value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                            message: "Enter a valid email",
                        },
                    })}
                />
                <Form.Control.Feedback type="invalid">
                    {errors.email?.message}
                </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3" controlId="formPassword">
                <Form.Label>Password</Form.Label>
                <Form.Control
                    type="password"
                    placeholder="Password"
                    isInvalid={!!errors.password}
                    {...register("password", {
                        required: "Password is required",
                        minLength: { value: 6, message: "Password must be at least 6 characters" },
                    })}
                />
                <Form.Control.Feedback type="invalid">
                    {errors.password?.message}
                </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3" controlId="formConfirmPassword">
                <Form.Label>Confirm Password</Form.Label>
                <Form.Control
                    type="password"
                    placeholder="Confirm Password"
                    isInvalid={!!errors.confirmPassword}
                    {...register("password_confirmation", {
                        required: "Confirm Password is required",
                        validate: (value) => value === password || "Passwords must match",
                    })}
                />
                <Form.Control.Feedback type="invalid">
                    {errors.confirmPassword?.message}
                </Form.Control.Feedback>
            </Form.Group>

            <Button variant="primary" type="submit" disabled={loading || isSubmitting}>
                {loading || isSubmitting ? <Spinner animation="border" size="sm" /> : "Register"}
            </Button>
        </Form>
    );
};

export default RegisterForm;