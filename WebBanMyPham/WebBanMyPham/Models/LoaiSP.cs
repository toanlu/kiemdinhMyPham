using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebBanMyPham.Models
{
    public class LoaiSP
    {
        string id, tenLoai;
        int maDanhMuc;

        public int MaDanhMuc
        {
            get { return maDanhMuc; }
            set { maDanhMuc = value; }
        }

        public string Id
        {
            get { return id; }
            set { id = value; }
        }

        public string TenLoai
        {
            get { return tenLoai; }
            set { tenLoai = value; }
        }
    }
}