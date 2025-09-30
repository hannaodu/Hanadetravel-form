# HanadeTravel Contact Form - Serverless AWS Solution
![alt text](<Screenshot 2025-09-30 at 11.41.00 PM.png>)

![alt text](<Screenshot 2025-09-30 at 11.58.56 PM.png>)


## 🚀 Project Overview

A fully functional, production-ready contact form for HanadeTravel built entirely on AWS serverless infrastructure. This solution handles form submissions, stores data in DynamoDB, and sends email notifications without managing any servers.

## ✨ Features

- **Responsive Contact Form** with modern UI/UX design
- **Serverless Architecture** - zero server management
- **Real-time Form Validation** and user feedback
- **Email Notifications** for new submissions
- **Secure Data Storage** in DynamoDB
- **CORS-enabled API** for cross-origin requests
- **Auto-scaling** and high availability

## 🏗️ Architecture

```
User Form (S3 Static Website) 
    → API Gateway (REST API)
    → Lambda Function (Node.js)
    → DynamoDB (Data Storage) + SES (Email Notifications)
```

## 📁 Project Structure

```
Hanadetravel-form/
├── frontend/
│   ├── index.html          # Main contact form
│   ├── styles.css          # Responsive styling
│   └── script.js           # Form handling & API integration
├── lambda/
│   ├── index.js            # Form processing logic
│   └── package.json        # AWS SDK dependencies
└── terraform/
    ├── main.tf             # Infrastructure as Code
    ├── variables.tf        # Configuration variables
    └── outputs.tf          # Deployment outputs
```

## 🛠️ Technologies Used

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: Node.js 18.x, AWS Lambda
- **Database**: Amazon DynamoDB (NoSQL)
- **Email**: Amazon SES (Simple Email Service)
- **Infrastructure**: Terraform (Infrastructure as Code)
- **Hosting**: Amazon S3 (Static Website)
- **API**: Amazon API Gateway (REST API)

## 🚀 Live Deployment

- **Website**: https://hanadetravel-form-website-49fb73d5.s3.eu-west-2.amazonaws.com/index.html
- **API Endpoint**: https://z9jnhfc9xd.execute-api.eu-west-2.amazonaws.com/production/contact

## 💾 Data Model

Form submissions are stored in DynamoDB with the following structure:
```javascript
{
  submissionId: "unique_timestamp_id",
  name: "Customer Name",
  email: "customer@email.com", 
  phone: "optional_phone",
  destination: "dream_destination",
  message: "customer_message",
  timestamp: "ISO_timestamp"
}
```

## 🔧 Key Features Implemented

### Frontend
- ✅ Responsive design with gradient backgrounds
- ✅ Form validation and error handling
- ✅ Loading states and success/error messages
- ✅ CORS-compliant API communication

### Backend
- ✅ Lambda function with proper error handling
- ✅ DynamoDB integration for data persistence
- ✅ SES integration for email notifications
- ✅ Input validation and sanitization

### Infrastructure
- ✅ Terraform-managed AWS resources
- ✅ Automated S3 deployment
- ✅ Proper IAM roles and permissions
- ✅ API Gateway configuration with CORS

## 🎯 Challenges Solved

1. **CORS Configuration** - Properly configured API Gateway for cross-origin requests
2. **Lambda Permissions** - Resolved IAM role permissions for DynamoDB and SES
3. **Form Styling Issues** - Fixed CSS and font rendering problems
4. **API Integration** - Established secure communication between frontend and backend
5. **Error Handling** - Implemented comprehensive error handling and user feedback

![alt text](<Screenshot 2025-09-30 at 11.59.50 PM.png>)

## 📈 Performance

- **Cold Start**: ~100-300ms (Lambda)
- **Form Submission**: < 2 seconds end-to-end
- **Availability**: 99.9%+ (AWS managed services)
- **Scalability**: Automatic scaling based on demand

## 🔒 Security

- IAM roles with least privilege principle
- Input validation and sanitization
- Secure environment variables
- CORS properly configured
- HTTPS enforcement

## 🚀 Getting Started

### Prerequisites
- AWS Account with appropriate permissions
- Terraform installed
- Node.js 18.x

### Deployment
1. Clone repository
2. Configure AWS credentials
3. Run `terraform apply`
4. Deploy frontend to S3


**Status**: ✅ Production Ready  
**Last Updated**: September 2025  
**Architecture**: Serverless AWS Stack



