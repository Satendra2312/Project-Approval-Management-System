import React, { useEffect } from "react";
import { useForm } from "react-hook-form";
import { Button, Form, Spinner } from "react-bootstrap";

const LoginForm = ({ onSubmit }) => {
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

    const watchFields = watch();

    // Focus first error field on submit
    useEffect(() => {
        const firstErrorField = Object.keys(errors)[0];
        if (firstErrorField) {
            setFocus(firstErrorField);
        }
    }, [errors, setFocus]);

    // Clear errors dynamically as the user corrects them
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

            <Button variant="primary" type="submit" disabled={isSubmitting}>
                {isSubmitting ? <Spinner animation="border" size="sm" /> : "Login"}
            </Button>
        </Form>
    );
};

export default LoginForm;
