// $(function() {
//     // the container div that holds the data attributes
//     var stepContainer;
//     var currentElement = $("#select-type");

//     var frames = {
//         ive: {
//             sub: 'inspired by Jony Ive.',
//             desc: 'The balance of roundness and depth complements the dimensions and angularity of most longer faces.',
//             size: {
//               small: "48mm",
//               large: "50.5mm"
//             },

//             sunglasses: {
//               black: {
//                 front: "<%= image_path('frames/ive/black-front.png') %>"
//               },
//               tortoise: {
//                 front: "<%= image_path('frames/ive/tortoise-front.png') %>"
//               }
//             },

//             optical: {
//               black: {
//                 front: "<%= image_path('frames/ive/optical-black-front.png') %>"
//               },
//               tortoise: {
//                 front: "<%= image_path('frames/ive/optical-tortoise-front.png') %>"
//               }
//             }
//         },

//         ford: {
//             sub: 'inspired by Tom Ford.',
//             desc: 'Strong curves and depth soften strong and angular features like prominent jaws and broader foreheads.',
//             size: {
//               small: "49mm",
//               large: "51.5mm"
//             },

//             sunglasses: {
//               black: {
//                 front: "<%= image_path('frames/ford-beta/black-front.png') %>"
//               },
//               tortoise: {
//                 front: "<%= image_path('frames/ford-beta/tortoise-front.png') %>"
//               }
//             },

//             optical: {
//               black: {
//                 front: "<%= image_path('frames/ford-beta/optical-black-front.png') %>"
//               },
//               tortoise: {
//                 front: "<%= image_path('frames/ford-beta/optical-tortoise-front.png') %>"
//               }
//             }

//         },
//     };


//   // type selection
//   $(".type-button#sunglasses").click(function(event) {
//     stepContainer.attr("data-type", "sunglasses");

//     setModelSelectionData(stepContainer.attr("data-type"));
//     fadeBetween(currentElement, $("#select-model"));
//   });

//   $(".type-button#optical").click(function(event) {
//     stepContainer.attr("data-type", "optical");

//     setModelSelectionData(stepContainer.attr("data-type"));
//     fadeBetween(currentElement, $("#select-model"));
//   });

//   function setModelSelectionData(type) {
//     $("#subheading").html("choose your style");
//     $("#progress").attr("class", "step-2");

//     $("#models #ford-model .select-model-image").attr("src", frames.ford[type].black.front)
//     $("#models #ive-model .select-model-image").attr("src", frames.ive[type].black.front)

//   }

//   // model selection
//   $("#models li#ford-model").click(function(event) {
//     stepContainer.attr("data-frame", "ford");

//     setColourSelectionData(stepContainer.attr("data-type"), stepContainer.attr("data-frame"));
//     fadeBetween(currentElement, $("#select-colour"));
//   });

//   $("#models li#ive-model").click(function(event) {
//     stepContainer.attr("data-frame", "ive");

//     setColourSelectionData(stepContainer.attr("data-type"), stepContainer.attr("data-frame"));
//     fadeBetween(currentElement, $("#select-colour"));
//   });

//   function setColourSelectionData(type, model) {
//     $("#subheading").html("choose your colour");
//     $("#progress").attr("class", "step-3");

//     $("#select-colour #colours #black-colour .select-colour-image").attr("src", frames[model][type].black.front);
//     $("#select-colour #colours #tortoise-colour .select-colour-image").attr("src", frames[model][type].tortoise.front);
//   }

//   // colour selection
//   $("#colours li#black-colour").click(function(event) {
//     stepContainer.attr("data-colour", "black");

//     setSizeSelectionData(stepContainer.attr("data-frame"));
//     fadeBetween(currentElement, $("#select-size"));
//   });

//   $("#colours li#tortoise-colour").click(function(event) {
//     stepContainer.attr("data-colour", "tortoise");

//     setSizeSelectionData(stepContainer.attr("data-frame"));
//     fadeBetween(currentElement, $("#select-size"));
//   });

//   function setSizeSelectionData(model, color) {
//     $("#subheading").html("choose your size");
//     $("#progress").attr("class", "step-4");


//     $("#sizes #small-size #size-header").html(frames[model].size.small);
//     $("#sizes #large-size #size-header").html(frames[model].size.large);
//   }

//   // size selection
//   $("#sizes li#small-size").click(function(event) {
//     stepContainer.attr("data-size", "s");

//     setPersonalDetailsData(stepContainer.attr("data-type"), stepContainer.attr("data-frame"), stepContainer.attr("data-colour"), stepContainer.attr("data-size"));
//     fadeBetween(currentElement, $("#enter-details"));
//   });

//   $("#sizes li#large-size").click(function(event) {
//     stepContainer.attr("data-size", "l");

//     setPersonalDetailsData(stepContainer.attr("data-type"), stepContainer.attr("data-frame"), stepContainer.attr("data-colour"), stepContainer.attr("data-size"));
//     fadeBetween(currentElement, $("#enter-details"));
//   });

//   function setPersonalDetailsData(type, model, colour, size) {
//     $("#subheading").html("enter your shipping details");
//     $("#progress").attr("class", "step-5");
//     $("#glasses-preview #glasses-preview-image").attr("src", frames[model][type][colour].front);
//     $("#glasses-details #type").html(type);
//     $("#glasses-details #frame").html(model);
//     $("#glasses-details #colour").html(colour);

//     if (size == "s") $("#glasses-details #size").html(frames[model].size.small);
//     if (size == "l") $("#glasses-details #size").html(frames[model].size.large);
//   }

//   // personal details collection
//   $('#details-form').submit(function(event) {
//     event.preventDefault();
//     $("#details-message").text("reserving your tzukuris...");

//     $.post('/betareservations',
//         { email: $('#email').val(),
//           name: $('#name').val(),
//           address1: $('#address1').val(),
//           address2: $('#address2').val(),
//           state: $('#state').val(),
//           postcode: $('#postcode').val(),
//           country: $('#country').val(),
//           frame: stepContainer.attr('data-frame'),
//           colour: stepContainer.attr('data-colour'),
//           size: stepContainer.attr('data-size'),
//           model: stepContainer.attr("data-type")
//         }).done(function(response) {
//           if (response.success) {
//             $("#progress").attr("class", "complete");
//             $("#header").fadeOut();

//             setTimeout(function() {
//               fadeBetween(currentElement, $("#complete"));
//             }, 200);
//           } else {
//             // todo: handle the error case
//             var errors = response.errors;
//             console.log(errors);

//             $("#details-message").text("some fields are incorrect or missing");

//             if (errors.name) {
//               $("#details-form p #name").attr("class", "error");
//             } else {
//               $("#details-form p #name").removeClass("error");
//             }

//             if (errors.email) {
//               $("#details-form p #email").attr("class", "error");
//             } else {
//               $("#details-form p #email").removeClass("error");
//             }

//             if (errors.address1) {
//               $("#details-form p #address1").attr("class", "error");
//             } else {
//               $("#details-form p #address1").removeClass("error");
//             }

//             if (errors.state) {
//               $("#details-form p #state").attr("class", "error");
//             } else {
//               $("#details-form p #state").removeClass("error");
//             }

//             if (errors.postcode) {
//               $("#details-form p #postcode").attr("class", "error");
//             } else {
//               $("#details-form p #postcode").removeClass("error");
//             }

//             if (errors.country) {
//               $("#details-form p #country").attr("class", "error");
//             } else {
//               $("#details-form p #country").removeClass("error");
//             }
//           }
//         }).fail( function(xhr, textStatus, errorThrown) {
//           $("#details-message").text("network error occured, please try again");
//         });
//   });

//   $('.back').click(function(event) {
//     var previousElement;

//     if (currentElement[0] == $("#select-model")[0]) {
//       $("#progress").attr("class", "step-1");
//       $("#subheading").html("choose your type of glasses");
//       previousElement = $("#select-type");
//     } else if (currentElement[0] == $("#select-colour")[0]) {
//       $("#progress").attr("class", "step-2");
//       $("#subheading").html("choose your style");
//       previousElement = $("#select-model");
//     } else if (currentElement[0] == $("#select-size")[0]){
//       $("#progress").attr("class", "step-3");
//       $("#subheading").html("choose your colour");
//       previousElement = $("#select-colour");
//     } else if (currentElement[0] == $("#enter-details")[0]) {
//       $("#progress").attr("class", "step-4");
//       $("#subheading").html("choose your size");
//       previousElement = $("#select-size");
//     }

//     fadeBetween(currentElement, previousElement);
//   });

//   function reset() {
//     // go back to the home view
//     fadeBetween(currentElement, $("#select-type"));

//     // show heading
//     setTimeout(function() {
//       $("#header").show();
//     }, 200);

//     // reset the progress view
//     $("#progress").attr("class", "step-1");

//     // clear out form data
//     $("#enter-details #form-container form")[0].reset();
//     $("#details-message").text("");
//     $("#subheading").html("choose your type of glasses");
//   }

//   $("#complete button").click(function() {
//     reset();
//   });

//   // document ready function
//   $( document ).ready(function() {
//     stepContainer = $("#steps-container");

//     // prevent the document from scrolling
//     // document.ontouchmove = function(e) {e.preventDefault()};
//   });

//   // helper functions
//   function fadeBetween(outElement, inElement) {
//     currentElement = inElement;

//     fadeDuration = 200;

//     outElement.fadeOut(fadeDuration);
//     setTimeout(function() {
//       inElement.fadeIn();
//     }, fadeDuration);
//   }

// });