// Wait for the page to load
document.addEventListener("DOMContentLoaded", function () {
  const contactForm = document.getElementById("contactForm");
  const submitBtn = document.getElementById("submitBtn");
  const messageArea = document.getElementById("messageArea");
  const btnText = submitBtn.querySelector(".btn-text");
  const btnLoading = submitBtn.querySelector(".btn-loading");

  // Form submission handler
  contactForm.addEventListener("submit", async function (event) {
    event.preventDefault(); // Stop form from reloading page

    // Show loading state
    btnText.style.display = "none";
    btnLoading.style.display = "inline";
    submitBtn.disabled = true;

    //  form data
    const formData = {
      name: document.getElementById("name").value,
      email: document.getElementById("email").value,
      phone: document.getElementById("phone").value,
      destination: document.getElementById("destination").value,
      message: document.getElementById("message").value,
    };

    try {
      // TODO:  API Gateway URL 
      const response = await fetch(
        "https://z9jnhfc9xd.execute-api.eu-west-2.amazonaws.com/production/contact",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(formData),
        }
      );

      const result = await response.json();

      if (response.ok) {
        showMessage(
          "Thank you! Your message has been sent successfully. We'll get back to you soon!",
          "success"
        );
        contactForm.reset(); // Clear the form
      } else {
        showMessage(
          "Sorry, there was an error sending your message. Please try again.",
          "error"
        );
      }
    } catch (error) {
      showMessage(
        "Network error. Please check your connection and try again.",
        "error"
      );
    } finally {
      // Reset button state
      btnText.style.display = "inline";
      btnLoading.style.display = "none";
      submitBtn.disabled = false;
    }
  });

  // Function to show messages
  function showMessage(text, type) {
    messageArea.textContent = text;
    messageArea.className = type;
    messageArea.style.display = "block";

    // Hide message after 5 seconds
    setTimeout(() => {
      messageArea.style.display = "none";
    }, 5000);
  }

  // Simple client-side validation
  contactForm.addEventListener("input", function (event) {
    const input = event.target;

    if (input.type === "email") {
      if (input.validity.typeMismatch) {
        input.setCustomValidity("Please enter a valid email address");
      } else {
        input.setCustomValidity("");
      }
    }
  });
});
