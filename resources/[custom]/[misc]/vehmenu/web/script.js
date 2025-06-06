function validatePosition(position) {
    return [
        Math.min(Math.max(position[0], 0), 1),
        Math.min(Math.max(position[1], 0), 1)
    ];
}

function showVehicleParts(data) {
    const [xPos, yPos] = validatePosition(data.position);
    const elementId = `#${data.id}`;
    if (!$(elementId).length) {
        $('body').append(`
            <p id="${data.id}" style="
                display: none;
                color: white;
                position: absolute;
                left: ${xPos * 100}vw;
                top: ${yPos * 100}vh;">
                ${data.html}
            </p>`);
        $(elementId).fadeIn(500);
    } else {
        $(elementId).css({
            left: `${xPos * 100}vw`,
            top: `${yPos * 100}vh`
        });
    }
    $(elementId).off().click(function () {
        $.post(`http://hrp-vehmenu/VehicleMenu`, JSON.stringify({
            id: data.id,
        }));
    });
}

window.addEventListener("message", function (event) {
    const data = event.data;
    switch (data.action) {
        case 'visible':
            showVehicleParts(data);
            break;
        case 'close':
            $('body').html('');
            break;
        case 'bonnet':
            $("#bonnet").remove();
            break;
    }
});
