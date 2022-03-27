using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanMyPham.Models;

namespace WebBanMyPham.Controllers
{
    public class DanhMucController : Controller
    {
        //
        // GET: /DanhMuc/
        DatabaseDataContext db = new DatabaseDataContext();
        public ActionResult FrameDanhMuc()
        {
            List<DanhMuc> lstDanhMuc = db.DANHMUCs.Select(item => new DanhMuc
            {
                Id = item.ID,
                TenDanhMuc = item.TENDANHMUC,
                LstLoaiSP = new List<LoaiSP>()
            }).ToList();

            // lấy lst loại sp
            var list = db.LOAISPs.Join(db.CHITIETDANHMUCs,
                    lsp => lsp.ID,
                    ctdMuc => ctdMuc.ID_LOAISP,
                    (lsp, ctdMuc) => new LoaiSP
                    {
                        Id = lsp.ID,
                        TenLoai = lsp.TENLOAI,
                        MaDanhMuc = ctdMuc.ID_DANHMUC
                    }
            ).ToList();

            lstDanhMuc.ForEach(itemDMuc =>
            {
                var lsp = list.Where(maDM => maDM.MaDanhMuc == itemDMuc.Id).ToList();
                itemDMuc.LstLoaiSP = lsp;
            });

            return View(lstDanhMuc);
        }

    }
}
