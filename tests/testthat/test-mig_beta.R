check_form <- function(x) {
  expect_is(x, "numeric")
  expect_true(length(x) == 103)
  expect_true(all(!is.na(x)))
  expect_named(x)
}

births <- c(719511L, 760934L, 772973L, 749554L, 760831L,
            828772L, 880543L, 905380L, 919639L)

test_that("mig_beta works without midyear", {

  res <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births
    )

  check_form(res)
})

test_that("mig_beta works with midyear", {

  res <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      midyear = TRUE
    )

  check_form(res)
})


test_that("mig_beta works well with age1", {

 res1 <- mig_beta(
    location = "Russian Federation",
    sex = "male",
    c1 = pop1m_rus2002,
    c2 = pop1m_rus2010,
    date1 = "2002-10-16",
    date2 = "2010-10-25",
    age1 = 0:100,
    births = c(719511L, 760934L, 772973L, 749554L,
               760831L, 828772L, 880543L, 905380L, 919639L)
  )

  # Same, but age args totally inferred.
  res2 <- mig_beta(
    location = "Russian Federation",
    sex = "male",
    c1 = pop1m_rus2002,
    c2 = pop1m_rus2010,
    date1 = "2002-10-16",
    date2 = "2010-10-25",
    births = c(719511L, 760934L, 772973L, 749554L,
               760831L, 828772L, 880543L, 905380L, 919639L))

  expect_equal(res1, res2)
})


test_that("Births are pulled from post-processed WPP2019", {
  # 2) births pulled from post-processing of WPP2019;
  #    mortality from WPP2019 (graduated as needed)

  outp <- capture_output_lines(
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100
    ))

  expect_true(any(outp == "births not provided. Downloading births for Russian Federation (LocID = 643), gender: `male`, years: 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010" #nolintr
  ))
})

test_that("mig_beta works well with different time points", {
  # 3) mortality (abridged, 2 and 3 time points) and fertility given:
  mortdate1 <- 2003
  mortdate2 <- 2006
  mortdate3 <- 2010
  age_lx <- c(0,1,seq(5,100,by=5))
  lx1 <- fertestr::FetchLifeTableWpp2019(
                     locations = "Russian Federation",
                     year = mortdate1,
                     sex = "male")$lx

  lx2 <- fertestr::FetchLifeTableWpp2019(
                     locations = "Russian Federation",
                     year = mortdate2, sex = "male")$lx

  lx3 <- fertestr::FetchLifeTableWpp2019(
                     locations = "Russian Federation",
                     year = mortdate3, sex = "male")$lx

  lxmat2 <- cbind(lx1,lx3)
  lxmat3 <- cbind(lx1,lx2,lx3)

  # with 2 mort timepoints
  res1 <- mig_beta(
   c1 = pop1m_rus2002,
   c2 = pop1m_rus2010,
   date1 = "2002-10-16",
   date2 = "2010-10-25",
   lxMat = lxmat2,
   dates_lx = c(mortdate1,mortdate3),
   age_lx = age_lx,
   births = c(719511L, 760934L, 772973L, 749554L,
              760831L, 828772L, 880543L, 905380L, 919639L),
   years_births = 2002:2010)

  check_form(res1)

  # with 3 mort timepoints
  res2 <- mig_beta(
   c1 = pop1m_rus2002,
   c2 = pop1m_rus2010,
   date1 = "2002-10-16",
   date2 = "2010-10-25",
   lxMat = lxmat3,
   dates_lx = c(mortdate1,mortdate2,mortdate3),
   age_lx = age_lx,
   births = c(719511L, 760934L, 772973L, 749554L,
              760831L, 828772L, 880543L, 905380L, 919639L),
   years_births = 2002:2010)

  check_form(res2)

  # Same as previous but with extra birth year specified (engage birth year filtering)
  res3 <- mig_beta(
   c1 = pop1m_rus2002,
   c2 = pop1m_rus2010,
   date1 = "2002-10-16",
   date2 = "2010-10-25",
   lxMat = lxmat3,
   dates_lx = c(mortdate1,mortdate2,mortdate3),
   age_lx = age_lx,
   births = c(719511L, 760934L, 772973L, 749554L,
              760831L, 828772L, 880543L, 905380L, 919639L,1e6),
   years_births = 2002:2011)

  check_form(res3)

})

test_that("mig_beta errors if not given correctly", {
  # 1) births given (no years_birth), but not right length
  expect_error(
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      # Here we provide births with one year less
      births = births[-length(births)]
    )
  )

  # 2) births given, correct length, but not right years
  expect_error(
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      # Correct births
      births = births,
      # Incorrect years of birth (should be 2010)
      years_births = 2002:2009
    )
  )
})

# Downloads data used below
mortdate1 <- 2003
mortdate2 <- 2006
mortdate3 <- 2010
age_lx <- c(0,1,seq(5,100,by=5))
lx1 <- fertestr::FetchLifeTableWpp2019(
                   locations = "Russian Federation",
                   year = mortdate1,
                   sex = "male")$lx

lx2 <- fertestr::FetchLifeTableWpp2019(
                   locations = "Russian Federation",
                   year = mortdate2, sex = "male")$lx

lx3 <- fertestr::FetchLifeTableWpp2019(
                   locations = "Russian Federation",
                   year = mortdate3, sex = "male")$lx

lxmat <- cbind(lx1,lx2,lx3)

# We should error if
test_that("mig_beta fails when lxmat is not correct", {

  # 3.1) lxMat given, but only one column
  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      lxMat = lxmat[, 1, drop = FALSE],
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010),
    regexp = "lxMat should have at least two or more dates as columns. lxMat contains only one column" #nolintr
  )

  ## 3.2) lxMat give, but the date range in it doesn't overlap
  ## with the date range of date1 to date2 (i.e. 100% extrapolation implied)
  expect_output(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2000-10-16",
      date2 = "2014-10-25",
      # Make up some very dates that are above 6 years within date1 and date2
      lxMat = lxmat[, 1:2],
      dates_lx = c(2007, 2008),
      age_lx = age_lx,
      # Make up some births to fit the dates from above.
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L,
                 919639L, 719511L, 760934L, 772973L,
                 749554L, 760831L, 828772L),
      years_births = 2000:2014),
    regexp = "Range between `date1` and `date2` must overlap with `lx_dates` for at least 25% of the range or 6 years." #nolintr
  )

  # Full error when dates_lx are now within the date1 and date2 threshold.
  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2000-10-16",
      date2 = "2014-10-25",
      # Make up some very long dates
      lxMat = lxmat[, 1:2],
      dates_lx = c(2020, 2021),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L,
                 919639L, 719511L, 760934L, 772973L,
                 749554L, 760831L, 828772L),
      years_births = 2000:2014),
    regexp = "All `dates_lx` must be within the range of `date1` and `date2`"
  )

})


# 4) age1 or age2 not single
test_that("Ages must be single in mig_beta", {

  # The error tests that they are the same length.
  # If ages are of anything other than single ages,
  # this will fail, capturing that the ages should
  # be single ages.
  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      # Supply ages in five year age groups
      age1 = seq(0, 100, by = 5),
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010),
    regexp = "length(age1) == length(c1) is not TRUE",
    fixed = TRUE
  )

  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      # Supply ages for second age group in five year age groups
      age2 = seq(0, 100, by = 5),
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010),
    regexp = "length(age2) == length(c2) is not TRUE",
    fixed = TRUE
  )

  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      # Both ages supplied
      age1 = seq(0, 100, by = 5),
      age2 = seq(0, 100, by = 5),
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010),
    regexp = "length(age1) == length(c1) is not TRUE",
    fixed = TRUE
  )
})

test_that("mig_beta fails if arguments not supplied to download data ", {

  # 5) no births given, and no location/sex given
  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      years_births = 2002:2010),
    regexp = "births not specified, please specify location and sex",
    fixed = TRUE
  )

  # 6) no lxMat given, and no location/sex given
  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010),
    regexp = "lxMat not specified, please specify location and sex",
    fixed = TRUE
  )
})

test_that("c1, c2 and lxmat should not have negatives", {

  # 7) c1, c2, lxMat, or births have negatives

  c1_neg <- pop1m_rus2002
  c1_neg[1] <- -c1_neg[1]

  expect_error(
    mig_beta(
      c1 = c1_neg,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010
    ),
    regexp = "No negative values allowed in `c1`"
  )

  c2_neg <- pop1m_rus2010
  c2_neg[1] <- -c2_neg[1]

  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = c2_neg,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010
    ),
    regexp = "No negative values allowed in `c2`"
  )

  lxmat_neg <- lxmat
  lxmat_neg[2, 1] <- -lxmat_neg[2, 1]

  expect_error(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      lxMat = lxmat_neg,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010
    ),
    regexp = "No negative values allowed in `lxMat`"
  )

})


test_that("mig_beta shows appropriate warnings when verbose = TRUE", {

  # 1) age1 and age2 not same range
  expect_output(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010[-length(pop1m_rus2010)],
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      # Both ages supplied
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L,
                 760831L, 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010),
    regexp = "\nFYI: age ranges are different for c1 and c2\nWe'll still get intercensal estimates,\nbut returned data will be chopped off after age 100 ",
    fixed = TRUE
  )

  # 2) date2 - date1 > 15
  expect_output(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      # Here I set the year to 2020
      date2 = "2017-10-25",
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      age_lx = age_lx,
      # Add fake births/years_births so that they exceed more
      # than 15 years
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L, 919639L,
                 760831L, 880543L, 719511L, 760934L, 772973L,
                 749554L),
      years_births = 2002:2017,
      verbose = TRUE
    ),
    regexp = "FYI, there are 15.02466 years between c1 and c2\nBe wary.",
    fixed = TRUE
  )

  # 3) if the shortest distance from dates_lx to date1 or date2 is greater than 7
  expect_output(
    mig_beta(
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2000-10-16",
      date2 = "2017-10-25",
      lxMat = lxmat[, 1:2],
      dates_lx = c(2008, 2009),
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L, 719511L,
                 760934L, 772973L, 749554L, 760831L, 828772L,
                 749554L, 760831L, 828772L),
      years_births = 2000:2017,
      verbose = TRUE
    ),
    regexp = "The shortest distance from `dates_lx` ( 2008 ) to `date1/date2`( 2000.79 ) is greater than 7 years. Be wary.",
    fixed = TRUE
  )

  # 4) any negatives detected in output (to be imputed with 0s)
  # TODO: I couldn't come up with an example where the resulting
  # interpolated values ended up being negative. Tim said these
  # would happen for very small cells. The idea would be to test
  # that the message is produced saying that negatives are being
  # replace by negatives and check that there are no negatives
  # in the output
  # c1 <- pop1m_rus2002
  # c1[100] <- 1
  # c1[101] <- 1
  # c2 <- pop1m_rus2002
  # c2[100] <- 1
  # c2[101] <- 1
  # set.seed(23151)
  # births <- sample(1:2, size = 10, replace = TRUE)
  # lxmat_dummy <- lxmat[, 1:2]
  # lxmat_dummy[22, ] <- c(0.000000000000001, 0.000000000000001)

  # mig_beta(
  #   c1 = c1,
  #   c2 = c2,
  #   date1 = "2000-10-16",
  #   date2 = "2009-10-25",
  #   lxMat = lxmat[, 1:2],
  #   dates_lx = c(2004, 2005),
  #   age_lx = age_lx,
  #   births = births,
  #   years_births = 2000:2009,
  #   verbose = TRUE
  # )
})

test_that("mig_beta throws download messages when verbose = TRUE", {

  # 1) lx is downloaded
  outp <- capture_output_lines(
    mig_beta(
      location = "Russian Federation",
      sex = "both",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010,
      verbose = TRUE
    ))
    expect_true(any(outp == "lxMat not provided. Downloading lxMat for Russian Federation (LocID = 643), gender: `both`, for years between 2002.8 and 2010.8"))

  # 2) births are downloaded
  outp <- capture_output_lines(
    mig_beta(
      location = "Russian Federation",
      sex = "both",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age_lx = age_lx,
      verbose = TRUE
    ))
  expect_true(any(outp == "births not provided. Downloading births for Russian Federation (LocID = 643), gender: `both`, years: 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010"))

  # 3) dates_lx or years_births are being assumed anything
  expect_output(
    mig_beta(
      location = "Russian Federation",
      sex = "both",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      lxMat = lxmat,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010,
      verbose = TRUE
    ),
    regexp = "lxMat specified, but not dates_lx\nAssuming: 2002.78904109589, 2006.80136986301, 2010.81369863014",
    fixed = TRUE
  )
})



test_that("mig_beta throws download messages when verbose = TRUE and LocID used", {

  # 1) lx is downloaded
  outp <- capture_output_lines(
    mig_beta(
      location = 643,
      sex = "both",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010,
      verbose = TRUE
    ))
  expect_true(any(outp == "lxMat not provided. Downloading lxMat for Russian Federation (LocID = 643), gender: `both`, for years between 2002.8 and 2010.8"))

  # 2) births are downloaded
  outp <- capture_output_lines(
    mig_beta(
      location = 643,
      sex = "both",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      lxMat = lxmat,
      dates_lx = c(mortdate1,mortdate2,mortdate3),
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age_lx = age_lx,
      verbose = TRUE
    ))
  expect_true(any(outp == "births not provided. Downloading births for Russian Federation (LocID = 643), gender: `both`, years: 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010"))

  # 3) dates_lx or years_births are being assumed anything
  expect_output(
    mig_beta(
      location = 643,
      sex = "both",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      lxMat = lxmat,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age_lx = age_lx,
      births = c(719511L, 760934L, 772973L, 749554L, 760831L,
                 828772L, 880543L, 905380L, 919639L),
      years_births = 2002:2010,
      verbose = TRUE
    ),
    regexp = "lxMat specified, but not dates_lx\nAssuming: 2002.78904109589, 2006.80136986301, 2010.81369863014",
    fixed = TRUE
  )
})


test_that("mig_beta applies child_adjustment correctly", {
  res_none <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      child_adjust = "none"
    )


  res_cwr <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      child_adjust = "cwr"
    )

  res_cwr_high <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      child_adjust = "cwr",
      cwr_factor = 0.9
    )

  res_constant <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      child_adjust = "constant"
    )

  # Check we don't mess up the format of migs (length, type, etc..)
  for (i in list(res_none, res_cwr, res_constant)) check_form(i)

  # Since cwr and constant can change, we only test that they adjust a certain
  # number of ages rather than test the exact equality of results.

  # CWR:
  # Why 9? Because date1 and date2 differ by 9 years, so only the first 9
  # cohorts are adjusted.
  # Test that the first 9 are adjusted:
  expect_true(all((res_none - res_cwr)[1:9] != 0))


  # Constant:
  # Testhat that the first 9 are adjusted.
  expect_true(all((res_none - res_constant)[1:9] != 0))


  # Test that CWR with high cwr_factor returns higher younger ages than with 0.3,
  # the default:
  expect_true(all(res_cwr_high[1:9] > res_cwr[1:9]))

})



test_that("mig_beta applies oldage_adjustment correctly", {
  res_none <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      oldage_adjust = "none"
    )

  res_beers <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      oldage_adjust = "beers"
    )


  res_mav <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      oldage_adjust = "mav"
    )

  # Check we don't mess up the format of migs (length, type, etc..)
  for (i in list(res_none, res_beers, res_mav)) check_form(i)

  # beers:
  # expect that the 65+ are different because they're adjusted
  # Why 66? Because first age is 0 and total length is 101
  expect_true(all((res_none - res_beers)[66:100] != 0))


  # mav:
  # expect that the 65+ are different because they're adjusted
  # Why 66? Because first age is 0 and total length is 101
  expect_true(all((res_none - res_mav)[66:100] != 0))


  # Test that oldage_min controls the age from which to adjust
  # old ages
  res_beers <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      oldage_adjust = "beers",
      oldage_min = 70
    )


  res_mav <-
    mig_beta(
      location = "Russian Federation",
      sex = "male",
      c1 = pop1m_rus2002,
      c2 = pop1m_rus2010,
      date1 = "2002-10-16",
      date2 = "2010-10-25",
      age1 = 0:100,
      births = births,
      oldage_adjust = "mav",
      oldage_min = 70
    )

  # beers:
  # expect that the 65+ are different because they're adjusted
  # Why 71? Because first age is 0 and total length is 101
  expect_true(all((res_none - res_beers)[71:100] != 0))


  # mav:
  # expect that the 65+ are different because they're adjusted
  # Why 71? Because first age is 0 and total length is 101
  expect_true(all((res_none - res_mav)[71:100] != 0))
})
