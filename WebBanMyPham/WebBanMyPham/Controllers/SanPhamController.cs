using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanMyPham.Models;
using PagedList;
using PagedList.Mvc;

namespace WebBanMyPham.Controllers
{
    public class SanPhamController : Controller
    {
        //
        // GET: /SanPham/
        DatabaseDataContext db = new DatabaseDataContext();
        public ActionResult SanPhamTheoLoai(string maLoai, int? page)
        {
            var listSP = db.SANPHAMs.Join(db.DONGIAs,
                                    sp => sp.ID,
                                    donGia => donGia.ID_SP,
                                    (sp, donGia) => new SanPham
                                    {
                                        Id = sp.ID,
                                        TenSP = sp.TENSP,
                                        SoLuong = int.Parse(sp.SOLUONG.Value.ToString()),
                                        IdLoaiSP = sp.ID_LOAI,
                                        HinhAnh = sp.HINHANH,
                                        Gia = double.Parse(donGia.GIA.Value.ToString())
                                    }).ToList();
            var lstSPTheoLoai = listSP.Where(sp => sp.IdLoaiSP == maLoai).ToList();
            return View(lstSPTheoLoai.ToPagedList(page ?? 1, 12));
        }
        public ActionResult XemChiTiet(string maSP)
        {
            var listSP = db.SANPHAMs.Join(db.DONGIAs,
                                    sp => sp.ID,
                                    donGia => donGia.ID_SP,
                                    (sp, donGia) => new SanPham
                                    {
                                        Id = sp.ID,
                                        TenSP = sp.TENSP,
                                        SoLuong = int.Parse(sp.SOLUONG.Value.ToString()),
                                        MoTa = sp.MOTA,
                                        IdLoaiSP = sp.ID_LOAI,
                                        HinhAnh = sp.HINHANH,
                                        Gia = double.Parse(donGia.GIA.Value.ToString())
                                    }).ToList();
            var sanPham = listSP.Single(sp => sp.Id == maSP);
            return View(sanPham);
        }

        public ActionResult SanPhamLQ(string maLoai, string tenSP)
        {
            var listSP = db.SANPHAMs.Join(db.DONGIAs,
                                    sp => sp.ID,
                                    donGia => donGia.ID_SP,
                                    (sp, donGia) => new SanPham
                                    {
                                        Id = sp.ID,
                                        TenSP = sp.TENSP,
                                        SoLuong = int.Parse(sp.SOLUONG.Value.ToString()),
                                        IdLoaiSP = sp.ID_LOAI,
                                        HinhAnh = sp.HINHANH,
                                        Gia = double.Parse(donGia.GIA.Value.ToString())
                                    }).ToList();

            var lstSPTheoLoai = listSP.Where(sp => sp.IdLoaiSP == maLoai && sp.TenSP != tenSP).Take(12).ToList();

            return View(lstSPTheoLoai);
        }

        public ActionResult TimKiemSanPham(string tenSP, int? page)
        {
            if (tenSP == string.Empty)
                return RedirectToAction("Index", "Home");

            ViewBag.TuKhoaTimKiem = tenSP;

            string sql = string.Format("select * from sanpham where tensp like N'%{0}%'", tenSP);

            var listSP = db.ExecuteQuery<SANPHAM>(sql).Join(db.DONGIAs,
                                    sp => sp.ID,
                                    donGia => donGia.ID_SP,
                                    (sp, donGia) => new SanPham
                                    {
                                        Id = sp.ID,
                                        TenSP = sp.TENSP,
                                        SoLuong = int.Parse(sp.SOLUONG.Value.ToString()),
                                        IdLoaiSP = sp.ID_LOAI,
                                        HinhAnh = sp.HINHANH,
                                        Gia = double.Parse(donGia.GIA.Value.ToString())
                                    }).ToList();

            return View(listSP.ToPagedList(page ?? 1, 12));
        }
    }
}
