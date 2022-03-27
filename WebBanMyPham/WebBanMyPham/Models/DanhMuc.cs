using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebBanMyPham.Models
{
    public class DanhMuc
    {
        string tenDanhMuc;
        List<LoaiSP> lstLoaiSP;

        public List<LoaiSP> LstLoaiSP
        {
            get { return lstLoaiSP; }
            set { lstLoaiSP = value; }
        }

        public string TenDanhMuc
        {
            get { return tenDanhMuc; }
            set { tenDanhMuc = value; }
        }
        int id;

        public int Id
        {
            get { return id; }
            set { id = value; }
        }
    }
}