const AWS = require("aws-sdk");
const ses = new AWS.SES();
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  // Set CORS headers
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json",
  };

  // Handle preflight OPTIONS request
  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: headers,
      body: "",
    };
  }

  try {
    // Parse the request body
    let body;
    try {
      body = JSON.parse(event.body);
    } catch (parseError) {
      return {
        statusCode: 400,
        headers: headers,
        body: JSON.stringify({
          error: "Invalid JSON in request body",
          message: "Please check your form data and try again.",
        }),
      };
    }

    // Validate required fields
    const { name, email, message } = body;

    if (!name || !email || !message) {
      return {
        statusCode: 400,
        headers: headers,
        body: JSON.stringify({
          error: "Missing required fields",
          message: "Name, email, and message are required.",
        }),
      };
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return {
        statusCode: 400,
        headers: headers,
        body: JSON.stringify({
          error: "Invalid email format",
          message: "Please provide a valid email address.",
        }),
      };
    }

    // Generate unique submission ID
    const submissionId =
      Date.now().toString() + Math.random().toString(36).substr(2, 9);
    const timestamp = new Date().toISOString();

    // Prepare data for DynamoDB
    const submissionData = {
      submissionId: submissionId,
      timestamp: timestamp,
      name: name.trim(),
      email: email.trim(),
      phone: body.phone ? body.phone.trim() : "Not provided",
      destination: body.destination ? body.destination.trim() : "Not specified",
      message: message.trim(),
      status: "processed",
    };

    // Save to DynamoDB
    await dynamodb
      .put({
        TableName: process.env.TABLE_NAME,
        Item: submissionData,
      })
      .promise();

    // Send confirmation email to customer
    const customerEmailParams = {
      Destination: {
        ToAddresses: [email],
      },
      Message: {
        Body: {
          Html: {
            Charset: "UTF-8",
            Data: `
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <style>
                                body { font-family: Arial, sans-serif; color: #333; }
                                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                                .header { background: linear-gradient(135deg, #3498db, #2980b9); color: white; padding: 20px; text-align: center; }
                                .content { padding: 20px; background: #f9f9f9; }
                                .footer { padding: 20px; text-align: center; color: #666; font-size: 12px; }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <div class="header">
                                    <h1>✈️ HanadeTravelEase</h1>
                                    <p>Thank You for Contacting Us!</p>
                                </div>
                                <div class="content">
                                    <h2>Hello ${name}!</h2>
                                    <p>We've received your inquiry and our travel experts will get back to you within 24 hours.</p>
                                    <p><strong>Your Message:</strong></p>
                                    <p>${message}</p>
                                    ${
                                      body.destination &&
                                      body.destination !== "Not specified"
                                        ? `<p><strong>Dream Destination:</strong> ${body.destination}</p>`
                                        : ""
                                    }
                                    <br>
                                    <p>Best regards,<br>The HanadeTravelEase Team</p>
                                </div>
                                <div class="footer">
                                    <p>This is an automated message. Please do not reply to this email.</p>
                                </div>
                            </div>
                        </body>
                        </html>
                        `,
          },
          Text: {
            Charset: "UTF-8",
            Data: `Hello ${name}!\n\nThank you for contacting HanadeTravelEase! We've received your message and will get back to you within 24 hours.\n\nYour message: ${message}\n\nBest regards,\nThe TravelEase Team`,
          },
        },
        Subject: {
          Charset: "UTF-8",
          Data: "✈️ Thank You for Contacting HanadeTravelEase!",
        },
      },
      Source: process.env.SENDER_EMAIL,
    };

    // Send notification email to business
    const businessEmailParams = {
      Destination: {
        ToAddresses: [process.env.BUSINESS_EMAIL],
      },
      Message: {
        Body: {
          Html: {
            Charset: "UTF-8",
            Data: `
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <style>
                                body { font-family: Arial, sans-serif; color: #333; }
                                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                                .header { background: #e74c3c; color: white; padding: 20px; text-align: center; }
                                .content { padding: 20px; background: #f9f9f9; }
                                .info-item { margin: 10px 0; }
                            </style>
                        </head>
                        <body>
                            <div class="container">
                                <div class="header">
                                    <h1>📧 New Contact Form Submission</h1>
                                </div>
                                <div class="content">
                                    <div class="info-item"><strong>Name:</strong> ${name}</div>
                                    <div class="info-item"><strong>Email:</strong> ${email}</div>
                                    <div class="info-item"><strong>Phone:</strong> ${
                                      body.phone || "Not provided"
                                    }</div>
                                    <div class="info-item"><strong>Destination:</strong> ${
                                      body.destination || "Not specified"
                                    }</div>
                                    <div class="info-item"><strong>Message:</strong><br>${message}</div>
                                    <div class="info-item"><strong>Submission ID:</strong> ${submissionId}</div>
                                    <div class="info-item"><strong>Received:</strong> ${new Date(
                                      timestamp
                                    ).toLocaleString()}</div>
                                </div>
                            </div>
                        </body>
                        </html>
                        `,
          },
          Text: {
            Charset: "UTF-8",
            Data: `New Contact Form Submission:\n\nName: ${name}\nEmail: ${email}\nPhone: ${
              body.phone || "Not provided"
            }\nDestination: ${
              body.destination || "Not specified"
            }\nMessage: ${message}\nSubmission ID: ${submissionId}\nReceived: ${timestamp}`,
          },
        },
        Subject: {
          Charset: "UTF-8",
          Data: `📧 New Contact: ${name} - TravelEase`,
        },
      },
      Source: process.env.SENDER_EMAIL,
    };

    // Send both emails
    await Promise.all([
      ses.sendEmail(customerEmailParams).promise(),
      ses.sendEmail(businessEmailParams).promise(),
    ]);

    console.log("Form submission processed successfully:", submissionId);

    return {
      statusCode: 200,
      headers: headers,
      body: JSON.stringify({
        message:
          "Form submitted successfully! Check your email for confirmation.",
        submissionId: submissionId,
      }),
    };
  } catch (error) {
    console.error("Error processing form submission:", error);

    return {
      statusCode: 500,
      headers: headers,
      body: JSON.stringify({
        error: "Internal server error",
        message:
          "Sorry, there was an error processing your submission. Please try again later.",
      }),
    };
  }
};
