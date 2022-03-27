using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebBanMyPham.Models
{
    public class SanPham
    {
        string id, tenSP, moTa, hinhAnh, idLoaiSP;

        public string IdLoaiSP
        {
            get { return idLoaiSP; }
            set { idLoaiSP = value; }
        }

        public string HinhAnh
        {
            get { return hinhAnh; }
            set { hinhAnh = value; }
        }

        public string MoTa
        {
            get { return moTa; }
            set { moTa = value; }
        }

        public string TenSP
        {
            get { return tenSP; }
            set { tenSP = value; }
        }

        public string Id
        {
            get { return id; }
            set { id = value; }
        }
        double gia;

        public double Gia
        {
            get { return gia; }
            set { gia = value; }
        }
        int soLuong;

        public int SoLuong
        {
            get { return soLuong; }
            set { soLuong = value; }
        }
    }
}