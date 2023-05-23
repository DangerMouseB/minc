; ModuleID = 'knight.c'
source_filename = "knight.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

@N = local_unnamed_addr global i32 0, align 4
@t = common local_unnamed_addr global i64* null, align 8
@.str = private unnamed_addr constant [7 x i8] c"t: %s\0A\00", align 1
@.str.1 = private unnamed_addr constant [6 x i8] c" %02d\00", align 1
@b = common local_unnamed_addr global i32** null, align 8



;; BOARD



; Function Attrs: nounwind ssp uwtable(sync)
define i32 @board() local_unnamed_addr #0 {
  %1 = load i64*, i64** @t, align 8, !tbaa !10
  %2 = call i64 @time(i64* noundef %1) #9
  %3 = load i64*, i64** @t, align 8, !tbaa !10
  %4 = call i8* @ctime(i64* noundef %3) #9
  %5 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i64 0, i64 0), i8* noundef %4)
  br label %6

6:                                                ; preds = %0, %18
  %7 = phi i64 [ 0, %0 ], [ %20, %18 ]
  br label %8

8:                                                ; preds = %6, %8
  %9 = phi i64 [ 0, %6 ], [ %16, %8 ]
  %10 = load i32**, i32*** @b, align 8, !tbaa !10
  %11 = getelementptr inbounds i32*, i32** %10, i64 %9
  %12 = load i32*, i32** %11, align 8, !tbaa !10
  %13 = getelementptr inbounds i32, i32* %12, i64 %7
  %14 = load i32, i32* %13, align 4, !tbaa !14
  %15 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32 noundef %14)
  %16 = add nuw nsw i64 %9, 1
  %17 = icmp eq i64 %16, 8
  br i1 %17, label %18, label %8, !llvm.loop !16

18:                                               ; preds = %8
  %19 = call i32 @putchar(i32 10)
  %20 = add nuw nsw i64 %7, 1
  %21 = icmp eq i64 %20, 8
  br i1 %21, label %22, label %6, !llvm.loop !19

22:                                               ; preds = %18
  %23 = call i32 @putchar(i32 10)
  ret i32 0
}

declare i64 @time(i64* noundef) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #2

declare i8* @ctime(i64* noundef) local_unnamed_addr #1



;; CHK



; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @chk(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, i32* %4, align 4
  store i32 %1, i32* %5, align 4
  %6 = load i32, i32* %4, align 4
  %7 = icmp slt i32 %6, 0
  br i1 %7, label %17, label %8

8:                                                ; preds = %2
  %9 = load i32, i32* %4, align 4
  %10 = icmp sgt i32 %9, 7
  br i1 %10, label %17, label %11

11:                                               ; preds = %8
  %12 = load i32, i32* %5, align 4
  %13 = icmp slt i32 %12, 0
  br i1 %13, label %17, label %14

14:                                               ; preds = %11
  %15 = load i32, i32* %5, align 4
  %16 = icmp sgt i32 %15, 7
  br i1 %16, label %17, label %18

5:                                                ; preds = %2
  %6 = load i32**, i32*** @b, align 8, !tbaa !10
  %7 = sext i32 %0 to i64
  %8 = getelementptr inbounds i32*, i32** %6, i64 %7
  %9 = load i32*, i32** %8, align 8, !tbaa !10
  %10 = sext i32 %1 to i64
  %11 = getelementptr inbounds i32, i32* %9, i64 %10
  %12 = load i32, i32* %11, align 4, !tbaa !14
  %13 = icmp eq i32 %12, 0
  %14 = zext i1 %13 to i32
  br label %15

15:                                               ; preds = %2, %5
  %16 = phi i32 [ %14, %5 ], [ 0, %2 ]
  ret i32 %16
}



;; GO



; Function Attrs: nounwind ssp uwtable(sync)
define i32 @go(i32 noundef %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #0 {
  %4 = load i32**, i32*** @b, align 8, !tbaa !10
  %5 = sext i32 %1 to i64
  %6 = getelementptr inbounds i32*, i32** %4, i64 %5
  %7 = load i32*, i32** %6, align 8, !tbaa !10
  %8 = sext i32 %2 to i64
  %9 = getelementptr inbounds i32, i32* %7, i64 %8
  store i32 %0, i32* %9, align 4, !tbaa !14
  %10 = icmp eq i32 %0, 64
  br i1 %10, label %13, label %11

11:                                               ; preds = %3
  %12 = add nsw i32 %0, 1
  br label %31

13:                                               ; preds = %3
  %14 = icmp ne i32 %1, 2
  %15 = icmp ne i32 %2, 0
  %16 = and i1 %14, %15
  br i1 %16, label %17, label %68

17:                                               ; preds = %13
  %18 = add nsw i32 %1, -2
  %19 = icmp slt i32 %1, 2
  %20 = sub i32 2, %1
  %21 = select i1 %19, i32 %20, i32 %18
  %22 = call i32 @llvm.abs.i32(i32 %2, i1 true)
  %23 = add nsw i32 %21, %22
  %24 = icmp eq i32 %23, 3
  br i1 %24, label %25, label %68

25:                                               ; preds = %17
  %26 = call i32 @board()
  %27 = load i32, i32* @N, align 4, !tbaa !14
  %28 = add nsw i32 %27, 1
  store i32 %28, i32* @N, align 4, !tbaa !14
  %29 = icmp eq i32 %28, 10
  br i1 %29, label %30, label %68

30:                                               ; preds = %25
  call void @exit(i32 noundef 0) #10
  unreachable

31:                                               ; preds = %11, %65
  %32 = phi i64 [ -2, %11 ], [ %66, %65 ]
  %33 = trunc i64 %32 to i32
  %34 = call i32 @llvm.abs.i32(i32 %33, i1 true)
  %35 = add nsw i64 %32, %5
  %36 = trunc i64 %35 to i32
  br label %37

37:                                               ; preds = %31, %62
  %38 = phi i64 [ -2, %31 ], [ %63, %62 ]
  %39 = trunc i64 %38 to i32
  %40 = call i32 @llvm.abs.i32(i32 %39, i1 true)
  %41 = add nuw nsw i32 %40, %34
  %42 = icmp eq i32 %41, 3
  br i1 %42, label %43, label %62

43:                                               ; preds = %37
  %44 = add nsw i64 %38, %8
  %45 = or i64 %44, %35
  %46 = and i64 %45, 4294967288
  %47 = icmp eq i64 %46, 0
  br i1 %47, label %48, label %56

48:                                               ; preds = %43
  %49 = load i32**, i32*** @b, align 8, !tbaa !10
  %50 = getelementptr inbounds i32*, i32** %49, i64 %35
  %51 = load i32*, i32** %50, align 8, !tbaa !10
  %52 = getelementptr inbounds i32, i32* %51, i64 %44
  %53 = load i32, i32* %52, align 4, !tbaa !14
  %54 = icmp eq i32 %53, 0
  %55 = zext i1 %54 to i32
  br label %56

56:                                               ; preds = %43, %48
  %57 = phi i32 [ %55, %48 ], [ 0, %43 ]
  %58 = icmp eq i32 %57, 0
  br i1 %58, label %62, label %59

59:                                               ; preds = %56
  %60 = trunc i64 %44 to i32
  %61 = call i32 @go(i32 noundef %12, i32 noundef %36, i32 noundef %60)
  br label %62

62:                                               ; preds = %37, %56, %59
  %63 = add nsw i64 %38, 1
  %64 = icmp eq i64 %63, 3
  br i1 %64, label %65, label %37, !llvm.loop !20

65:                                               ; preds = %62
  %66 = add nsw i64 %32, 1
  %67 = icmp eq i64 %66, 3
  br i1 %67, label %68, label %31, !llvm.loop !21

68:                                               ; preds = %65, %13, %17, %25
  %69 = load i32**, i32*** @b, align 8, !tbaa !10
  %70 = getelementptr inbounds i32*, i32** %69, i64 %5
  %71 = load i32*, i32** %70, align 8, !tbaa !10
  %72 = getelementptr inbounds i32, i32* %71, i64 %8
  store i32 0, i32* %72, align 4, !tbaa !14
  ret i32 0
}

; Function Attrs: noreturn
declare void @exit(i32 noundef) local_unnamed_addr #4



;; MAIN



; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() local_unnamed_addr #0 {
  %1 = call dereferenceable_or_null(8) i8* @malloc(i64 noundef 8) #11
  %2 = bitcast i8* %1 to i64*
  store i8* %1, i8** bitcast (i64** @t to i8**), align 8, !tbaa !10
  %3 = call i64 @time(i64* noundef %2) #9
  %4 = load i64*, i64** @t, align 8, !tbaa !10
  %5 = call i8* @ctime(i64* noundef %4) #9
  %6 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i64 0, i64 0), i8* noundef %5)
  %7 = call dereferenceable_or_null(64) i8* @calloc(i64 noundef 8, i64 noundef 8) #12
  store i8* %7, i8** bitcast (i32*** @b to i8**), align 8, !tbaa !10
  br label %8

8:                                                ; preds = %0, %8
  %9 = phi i64 [ 0, %0 ], [ %14, %8 ]
  %10 = call dereferenceable_or_null(32) i8* @calloc(i64 noundef 8, i64 noundef 4) #12
  %11 = load i32**, i32*** @b, align 8, !tbaa !10
  %12 = getelementptr inbounds i32*, i32** %11, i64 %9
  %13 = bitcast i32** %12 to i8**
  store i8* %10, i8** %13, align 8, !tbaa !10
  %14 = add nuw nsw i64 %9, 1
  %15 = icmp eq i64 %14, 8
  br i1 %15, label %16, label %8, !llvm.loop !22

16:                                               ; preds = %8
  %17 = call i32 @go(i32 noundef 1, i32 noundef 2, i32 noundef 0)
  ret i32 0
}

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0)
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #5

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0,1)
declare noalias noundef i8* @calloc(i64 noundef, i64 noundef) local_unnamed_addr #6

; Function Attrs: nofree nounwind
declare noundef i32 @putchar(i32 noundef) local_unnamed_addr #7

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.abs.i32(i32, i1 immarg) #8

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #2 = { nofree nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #3 = { mustprogress nofree norecurse nosync nounwind readonly ssp willreturn uwtable(sync) "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #4 = { noreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #5 = { inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #6 = { inaccessiblememonly mustprogress nofree nounwind willreturn allocsize(0,1) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #7 = { nofree nounwind }
attributes #8 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #9 = { nounwind }
attributes #10 = { noreturn nounwind }
attributes #11 = { allocsize(0) }
attributes #12 = { allocsize(0,1) }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!llvm.ident = !{!9}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 13, i32 3]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"branch-target-enforcement", i32 0}
!3 = !{i32 8, !"sign-return-address", i32 0}
!4 = !{i32 8, !"sign-return-address-all", i32 0}
!5 = !{i32 8, !"sign-return-address-with-bkey", i32 0}
!6 = !{i32 7, !"PIC Level", i32 2}
!7 = !{i32 7, !"uwtable", i32 1}
!8 = !{i32 7, !"frame-pointer", i32 1}
!9 = !{!"Apple clang version 14.0.3 (clang-1403.0.22.14.1)"}
!10 = !{!11, !11, i64 0}
!11 = !{!"any pointer", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = !{!15, !15, i64 0}
!15 = !{!"int", !12, i64 0}
!16 = distinct !{!16, !17, !18}
!17 = !{!"llvm.loop.mustprogress"}
!18 = !{!"llvm.loop.unroll.disable"}
!19 = distinct !{!19, !17, !18}
!20 = distinct !{!20, !17, !18}
!21 = distinct !{!21, !17, !18}
!22 = distinct !{!22, !17, !18}
