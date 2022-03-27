$('#btnSignupInfo').click(function () {
    const name_ = $('#floatingNameSignup').val();
    const username_ = $('#floatingUsernameSignup').val();
    const pw_ = $('#floatingPasswordSignup').val();
    const email_ = $('#floatingEmailSignup').val();
    const tel_ = $('#floatingPhoneSignup').val();
    const gioiTinh_ = $("input[name=GioiTinh]:checked").val();
    const ngSinh_ = $("#floatingNgSinhSignup").val();

    $('#floatingNameSignup, #floatingUsernameSignup, #floatingPasswordSignup, #floatingEmailSignup, #floatingPhoneSignup, #floatingNgSinhSignup').css({
        'border': ''
    })

    if (name_.trim().length==0 || username_.trim().length==0 || pw_.trim().length==0 || email_.trim().length==0 || tel_.trim().length==0 || ngSinh_.trim().length==0)
    {
        Toast.fire({
            icon: 'error', 
            title: 'Vui lòng nhập đầy đủ thông tin!' 
        });
        $('#floatingNameSignup, #floatingUsernameSignup, #floatingPasswordSignup, #floatingEmailSignup, #floatingPhoneSignup, #floatingNgSinhSignup').css({
            'border': '1px solid red'
        })
        return;
    }
    if (!validateEmail(email_))
    {
        Toast.fire({
            icon: 'error', 
            title: 'Email không hợp lợi.Vui lòng nhập lại.' 
        });
        $('#floatingNameSignup, #floatingUsernameSignup, #floatingPasswordSignup, #floatingPhoneSignup').css({
            'border': ''
        });
        $('#floatingEmailSignup').css({
            'border': '1px solid red'
        })
        return;
    }
    if (!validateTel(tel_))
    {
        Toast.fire({
            icon: 'error', 
            title: 'Số điện thoại không hợp lợi.Vui lòng nhập lại.' 
        });
        $('#floatingNameSignup, #floatingUsernameSignup, #floatingPasswordSignup, #floatingEmailSignup').css({
            'border': ''
        });
        $('#floatingPhoneSignup').css({
            'border': '1px solid red'
        })
        return;
    }


    const jsonInfo = {
        Tk: {
            Username: username_,
            Pw: pw_,
        },
        HoTen: name_,
        Email: email_,
        Sdt: tel_,
        NgaySinh: ngSinh_,
        GioiTinh: gioiTinh_
    };

    $.ajax({
        url: '/Auth/DangKy',
        data: `{signup: ${JSON.stringify(jsonInfo)}}`,
        type: 'POST',
        contentType:"application/json; charset=utf-8",
        success: (data) => {
            const message = data;
            switch(message) {
                case "Success":
                    Toast.fire({
                        icon: 'success', 
                        title: 'Đăng ký thành công' 
                    });
                    modalSignup.toggle();

                    $('#floatingNameSignup').val('');
                    $('#floatingUsernameSignup').val('');
                    $('#floatingPasswordSignup').val('');
                    $('#floatingEmailSignup').val('');
                    $('#floatingPhoneSignup').val('');
                    $('#floatingNgSinhSignup').val('');
                    break;
                case "fail":
                    Toast.fire({
                        icon: 'error', 
                        title: 'Đăng ký thất bại. Vui lòng thử lại' 
                    });
                    break;
                case "username":
                    {
                        $('#floatingUsernameSignup').css({
                            'border': '1px solid red'
                        });
                        Toast.fire({
                            icon: 'error', 
                            title: 'Username đã tồn tại. Vui lòng nhập lại' 
                        });
                    } break;
                }
            },
            error: (request, error) => {
                // This callback function will trigger on unsuccessful action                
                Toast.fire({
                    icon: 'error', 
                    title: 'Đã xảy ra lỗi! Vui lòng thử lại.' 
                });
            }
        });
    
});