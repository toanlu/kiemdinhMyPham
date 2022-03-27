using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
namespace WebBanMyPham.Models
{
    public class ThongTinNguoiDung
    {
        public tinh_ThanhPho TinhTP { get; set; }
        public huyen_thanh Huyen { get; set; }
        public Phuong_Xa Phuong {get;set; }


        string hoTen, email, sdt, gioiTinh;
        TaiKhoan tk;
        DateTime ngaySinh;

        [Required(ErrorMessage = "Vui lòng nhập họ tên của bạn !")]
        [StringLength(50, MinimumLength = 10, ErrorMessage = "Vui lòng nhập đầy đủ họ va tên !")]
        public string HoTen
        {
            get { return hoTen; }
            set { hoTen = value; }
        }

        [Required(ErrorMessage = "Vui lòng nhập địa chỉ của bạn !")]
        [StringLength(50, ErrorMessage = "Địa chỉ không hợp lệ !")]
        public string diaChi { get; set; }
       
        public TaiKhoan Tk
        {
            get { return tk; }
            set { tk = value; }
        }

        public DateTime NgaySinh
        {
            get { return ngaySinh; }
            set { ngaySinh = value; }
        }
        [Required(ErrorMessage = "Vui lòng nhập số điện thoại của bạn!")]
        [DataType(DataType.PhoneNumber)]
        [RegularExpression(@"^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$", ErrorMessage = "Số điện thoại không hợp lệ")]
        public string Sdt
        {
            get { return sdt; }
            set { sdt = value; }
        }

        [Required(ErrorMessage = "Vui lòng nhập email của bạn !")]
        [EmailAddress(ErrorMessage = "Địa chỉ email không hợp lệ !")]
        public string Email
        {
            get { return email; }
            set { email = value; }
        }

        public string GioiTinh
        {
            get { return gioiTinh; }
            set { gioiTinh = value; }
        }

      
       
    }
    public enum tinh_ThanhPho
    {
        Tphcm,
        hanoi,
        NhaTrang,
        NgheAn
    }

    public enum huyen_thanh
    {
       quan11,
       quan1,
       quan12
            
    }

    public enum Phuong_Xa
    {
       phuong1,
       phuong2,
       phuong3
    }
}