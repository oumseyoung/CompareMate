document.addEventListener("DOMContentLoaded", function () {
    const endDateInput = document.getElementById("end-date");
    const endTimeInput = document.getElementById("end-time");

    const now = new Date();
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const yyyy = tomorrow.getFullYear();
    const mm = String(tomorrow.getMonth() + 1).padStart(2, "0");
    const dd = String(tomorrow.getDate()).padStart(2, "0");
    const hh = String(tomorrow.getHours()).padStart(2, "0");
    const min = String(tomorrow.getMinutes()).padStart(2, "0");

    endDateInput.value = `${yyyy}-${mm}-${dd}`;
    endTimeInput.value = `${hh}:${min}`;
});
